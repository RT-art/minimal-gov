#!/usr/bin/env bash
set -euo pipefail

# Run from repo root regardless of invocation path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

run_apply() {
  local profile="$1"; shift
  local dir_rel="$1"; shift
  echo "Applying in ${dir_rel} ..."
  (cd "$REPO_ROOT/${dir_rel}" && AWS_PROFILE="$profile" terragrunt apply -auto-approve)
}

# ===== network アカウント =====
run_apply network "infra/envs/network/tgw_hub"
run_apply network "infra/envs/network/vpc"
run_apply network "infra/envs/network/tgw_attachment"
run_apply network "infra/envs/network/vpc_route_to_tgw"

# ===== dev アカウント =====
run_apply dev "infra/envs/dev/network/vpc"
run_apply dev "infra/envs/dev/network/tgw_attachment"

echo "All applies completed successfully."
