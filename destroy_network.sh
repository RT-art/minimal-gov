#!/usr/bin/env bash
set -euo pipefail

# Run from repo root regardless of invocation path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

run_destroy() {
  local profile="$1"; shift
  local dir_rel="$1"; shift
  echo "Destroying in ${dir_rel} ..."
  (cd "$REPO_ROOT/${dir_rel}" && AWS_PROFILE="$profile" terragrunt destroy -auto-approve)
}

# ===== network アカウント =====
run_destroy network "infra/envs/network/tgw_route"
run_destroy network "infra/envs/network/vpc_route_to_tgw"
run_destroy network "infra/envs/network/tgw_attachment_accepter"

# ===== dev アカウント =====
run_destroy dev "infra/envs/dev/network/tgw_attachment"
run_destroy dev "infra/envs/dev/network/vpc"

# ===== network アカウント =====
run_destroy network "infra/envs/network/tgw_attachment"
run_destroy network "infra/envs/network/vpc"
run_destroy network "infra/envs/network/tgw_hub"

echo "All destroys completed successfully."
