#!/bin/bash
set -euo pipefail

# ===== network アカウント =====
echo "Destroying in network/tgw_route ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/tgw_route
AWS_PROFILE=network terragrunt destroy -auto-approve

echo "Destroying in dev/network/vpc_route_to_tgw ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/vpc_route_to_tgw
AWS_PROFILE=network terragrunt destroy -auto-approve

echo "Destroying in network/tgw_attachment_accepter ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/tgw_attachment_accepter
AWS_PROFILE=network terragrunt destroy -auto-approve

# ===== dev アカウント =====
echo "Destroying in dev/network/tgw_attachment ..."
cd /home/rt/work/github/minimal-gov/infra/envs/dev/network/tgw_attachment
AWS_PROFILE=dev terragrunt destroy -auto-approve

echo "Destroying in dev/network/vpc ..."
cd /home/rt/work/github/minimal-gov/infra/envs/dev/network/vpc
AWS_PROFILE=dev terragrunt destroy -auto-approve

# ===== network アカウント =====
echo "Destroying in network/vpc_route_to_tgw ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/vpc_route_to_tgw
AWS_PROFILE=network terragrunt destroy -auto-approve

echo "Destroying in network/tgw_attachment ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/tgw_attachment
AWS_PROFILE=network terragrunt destroy -auto-approve

echo "Destroying in network/vpc ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/vpc
AWS_PROFILE=network terragrunt destroy -auto-approve

echo "Destroying in network/tgw_hub ..."
cd /home/rt/work/github/minimal-gov/infra/envs/network/tgw_hub
AWS_PROFILE=network terragrunt destroy -auto-approve

echo "All destroys completed successfully."
