#!/usr/bin/env bash

set -euo pipefail

# Orchestrate Terragrunt applies across Network and Dev accounts.
# - Switches AWS_PROFILE between "network" and "dev" as needed
# - Applies modules in dependency-safe order
# - Skips Organization, CI/CD roles, state-backend, and VPC peering
#
# Usage:
#   chmod +x infra/bin/apply_dev_network.sh
#   infra/bin/apply_dev_network.sh            # apply all
#   infra/bin/apply_dev_network.sh --plan     # plan only (no apply)
#   DEV_PROFILE=dev NETWORK_PROFILE=network infra/bin/apply_dev_network.sh
#
# Requirements:
#   - terragrunt and terraform installed
#   - AWS named profiles available: $NETWORK_PROFILE and $DEV_PROFILE
#   - Backend/state bucket pre-provisioned (this script does NOT create it)

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
BASE_DIR="$ROOT_DIR/infra/envs/dev"

NETWORK_PROFILE=${NETWORK_PROFILE:-network}
DEV_PROFILE=${DEV_PROFILE:-dev}

MODE="apply"  # or "plan"
AUTO_APPROVE=(-auto-approve)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan)
      MODE="plan"
      AUTO_APPROVE=()
      shift
      ;;
    -y|--yes)
      AUTO_APPROVE=(-auto-approve)
      shift
      ;;
    -h|--help)
      cat <<USAGE
Orchestrate Terragrunt across network/dev accounts.

Usage:
  $(basename "$0") [--plan] [-y|--yes]

Env:
  NETWORK_PROFILE  (default: network)
  DEV_PROFILE      (default: dev)
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
      terragrunt plan -input=false; \
    else \
      terragrunt apply -input=false "${AUTO_APPROVE[@]}"; \
    fi \
  )
}

#
# Dependency-aware order
#
# Notes:
# - Cross-account TGW flow:
#     1) network/tgw_hub (network)
#     2) network/tgw_attachment (network VPC -> TGW)
#     3) workload/network/tgw_attachment (dev VPC -> TGW)
#     4) network/tgw_attachment_accepter (accept dev attachment in network)
#     5) network/tgw_route (wire attachments + routing tables)
#     6) {network,workload}/vpc_route_to_tgw (add VPC routes to each other)
# - Excluded categories: organization/*, */cicd/*, */state_backend/*, */peering/*

# 1) Core VPCs
run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/vpc"          "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/network/vpc" "$MODE"

SKIP_TGW_HUB=${SKIP_TGW_HUB:-}
SKIP_TGW_ALL=${SKIP_TGW_ALL:-}

# 2) TGW Hub + Attachments
if [[ -z "$SKIP_TGW_ALL" ]]; then
  if [[ -z "$SKIP_TGW_HUB" ]]; then
    run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/tgw_hub"       "$MODE"
  else
    echo "\n=== [network] skip: envs/dev/network/tgw_hub (SKIP_TGW_HUB set) ==="
  fi

  run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/tgw_attachment" "$MODE"
  run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/network/tgw_attachment" "$MODE"
  run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/tgw_attachment_accepter" "$MODE"

  # 3) TGW Routing
  run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/tgw_route" "$MODE"
  run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/vpc_route_to_tgw" "$MODE"
  run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/network/vpc_route_to_tgw" "$MODE"
else
  echo "\n=== [all] skip: TGW steps (SKIP_TGW_ALL set) ==="
fi

# 4) Endpoints (after VPCs are ready)
run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/endpoint"          "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/network/endpoint" "$MODE"

# 5) Optional compute/network extras (no org/cicd/state/peering)
run_tg "$NETWORK_PROFILE" "$BASE_DIR/network/ec2" "$MODE"           # bastion
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/ecr" "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/alb" "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/db"  "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/dns" "$MODE"
run_tg "$DEV_PROFILE"     "$BASE_DIR/workload/app" "$MODE"

echo "\nAll done."
