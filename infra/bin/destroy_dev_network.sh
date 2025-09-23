#!/usr/bin/env bash

set -euo pipefail

# Orchestrate Terragrunt destroys across Network and Dev accounts.
# - Switches AWS_PROFILE between "network" and "dev" as needed
# - Destroys modules in reverse dependency order
# - Skips Organization, CI/CD roles, state-backend, and VPC peering
#
# Usage:
#   chmod +x infra/bin/destroy_dev_network.sh
#   infra/bin/destroy_dev_network.sh            # interactive destroy
#   infra/bin/destroy_dev_network.sh --plan     # plan only (no destroy)
#   infra/bin/destroy_dev_network.sh -y         # auto-approve destroy
#   DEV_PROFILE=dev NETWORK_PROFILE=network infra/bin/destroy_dev_network.sh
#
# Requirements:
#   - terragrunt and terraform installed
#   - AWS named profiles available: $NETWORK_PROFILE and $DEV_PROFILE
#   - Backend/state bucket pre-provisioned (this script does NOT create it)

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
BASE_DIR="$ROOT_DIR/infra/envs/dev"

NETWORK_PROFILE=${NETWORK_PROFILE:-network}
DEV_PROFILE=${DEV_PROFILE:-dev}

MODE="destroy"  # or "plan"
AUTO_APPROVE=()  # set to (-auto-approve) when -y given

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan)
      MODE="plan"
      shift
      ;;
    -y|--yes)
      AUTO_APPROVE=(-auto-approve)
      shift
      ;;
    -h|--help)
      cat <<USAGE
Orchestrate Terragrunt destroys across network/dev accounts.

Usage:
  $(basename "$0") [--plan] [-y|--yes]

Env:
  NETWORK_PROFILE  (default: network)
  DEV_PROFILE      (default: dev)

Notes:
  Without -y/--yes, destroy runs interactively per module.
USAGE
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' not found in PATH" >&2
    exit 1
  fi
}

require_cmd terragrunt
require_cmd terraform

run_tg() {
  local profile="$1"; shift
  local dir="$1"; shift
  local mode="$1"; shift

  if [[ ! -d "$dir" ]]; then
    echo "[SKIP] $dir (not found)"
    return 0
  fi

  echo "\n=== [$profile] $mode: $(realpath --relative-to="$ROOT_DIR" "$dir") ==="
  ( \
    export AWS_PROFILE="$profile"; \
    cd "$dir"; \
    if [[ "$mode" == "plan" ]]; then \
      terragrunt plan -destroy -input=false; \
    else \
      terragrunt destroy -input=false "${AUTO_APPROVE[@]}"; \
    fi \
  )
}

#
# Reverse dependency order (destroy dependents first)
#
# Apply order reference (from apply_dev_network.sh):
#   1) network/vpc, workload/network/vpc
#   2) tgw_hub -> tgw_attachment -> workload tgw_attachment -> accepter
#      -> tgw_route -> vpc_route_to_tgw (network/workload)
#   3) endpoints (network/workload)
#   4) extras: network/ec2, workload/{ecr,alb,db,dns,app}
#
# Destroy order below reverses the above safely.

# 1) Extras first
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/app" "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/dns" "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/db"  "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/alb" "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/ecr" "$MODE"
run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/ec2" "$MODE"           # bastion

# 2) Endpoints next (so VPCs can be destroyed later)
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/network/endpoint" "$MODE"
run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/endpoint"          "$MODE"

SKIP_TGW_HUB=${SKIP_TGW_HUB:-}
SKIP_TGW_ALL=${SKIP_TGW_ALL:-}

# 3) TGW-related resources (routes -> accepter -> attachments -> hub)
if [[ -z "$SKIP_TGW_ALL" ]]; then
  run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/network/vpc_route_to_tgw" "$MODE"
  run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/vpc_route_to_tgw" "$MODE"
  run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/tgw_route" "$MODE"

  run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/tgw_attachment_accepter" "$MODE"
  run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/network/tgw_attachment" "$MODE"
  run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/tgw_attachment" "$MODE"

  if [[ -z "$SKIP_TGW_HUB" ]]; then
    run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/tgw_hub" "$MODE"
  else
    echo "\n=== [network] skip: envs/dev/network/tgw_hub (SKIP_TGW_HUB set) ==="
  fi
else
  echo "\n=== [all] skip: TGW steps (SKIP_TGW_ALL set) ==="
fi

# 4) VPCs last
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/network/vpc" "$MODE"
run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/vpc"          "$MODE"

echo "\nAll done."

