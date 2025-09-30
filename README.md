# Minimal Gov

## Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)

![Organization Diagram](./image/Organization.png)

## Version

- Terraform/Provider versions
  - Terraform: `>= 1.9.0, < 2.0.0`
  - AWS Provider: `~> 6.14`（Terragrunt/直Terraform の両方で統一）

## Runbook

1. 組織アカウントで `infra/organization/state_backend` → `infra/organization/organizations` → `infra/organization/delegations` の順に `terraform apply`。`allowed_account_ids` と `add_scps` の設定値を実環境のアカウント/OUに差し替える。 
2. ネットワークアカウントで `cd infra/envs/prod/network`（必要に応じて `dev`）して `terragrunt run-all apply`。Transit Gateway / RAM 共有が完了する前にワークロード側を叩かない。 
3. ワークロードアカウントで `cd infra/envs/prod/workloads` し、同様に `terragrunt run-all apply`。Network の TGW state を取得できることを確認。 
4. GitHub OIDC ロールに必要最小限の IAM ポリシーを割り当て（既定は `PowerUserAccess` + `AWSOrganizationsFullAccess` + `IAMFullAccess`）。不足があれば `managed_policy_arns` を更新。 
5. 構築後、SSM 経由でネットワーク EC2 に接続し、内部 ALB (`app.<private zone>`) 経由で ECS アプリに HTTP アクセス → RDS 接続まで確認。VPC ルート、TGW 伝播、Security Group ログで疎通を検証する。 
