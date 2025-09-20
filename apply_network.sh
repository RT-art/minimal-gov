#!/bin/bash
set -euo pipefail

# ===== network アカウント =====
echo "Applying in network/tgw_hub ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/tgw_hub
AWS_PROFILE=network terragrunt apply -auto-approve

echo "Applying in network/vpc ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/vpc
AWS_PROFILE=network terragrunt apply -auto-approve

echo "Applying in network/tgw_attachment ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/tgw_attachment
AWS_PROFILE=network terragrunt apply -auto-approve

echo "Applying in network/vpc_route_to_tgw ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/vpc_route_to_tgw
AWS_PROFILE=network terragrunt apply -auto-approve

# ===== dev アカウント =====
echo "Applying in dev/network/vpc ..."
cd /home/rt/work/github/minimal-gov/infra/envs/dev/network/vpc
AWS_PROFILE=dev terragrunt apply -auto-approve

echo "Applying in dev/network/tgw_attachment ..."
cd /home/rt/work/github/minimal-gov/infra/envs/dev/network/tgw_attachment
AWS_PROFILE=dev terragrunt apply -auto-approve

echo "All applies completed successfully."
