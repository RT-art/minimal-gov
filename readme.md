# Minimal Gov

## Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)

![Organization Diagram](./image/Organization.png)

## Version

- Terraform/Provider versions
  - Terraform: `>= 1.9.0, < 2.0.0`
  - AWS Provider: `~> 6.14`（Terragrunt/直Terraform の両方で統一）

## How To Review (採用担当・面接官向け)

- 目的: コードと設計を短時間で把握できるようにするためのガイドです。
- 前提: 実環境への `apply` は想定していません（コスト/権限/リスクのため）。
- 推奨の見方:
  - アーキテクチャ図とリポジトリ構成を眺める
  - モジュール実装（`infra/modules/**`）を読む
  - 必要ならプランだけ（`plan`）を確認（安全・非破壊）

## Quick Start（安全に確認する方法）

1) ツールのバージョンを合わせる（任意）
- `.terraform-version` / `.terragrunt-version` に合わせて `tfenv`/`tgenv` などで合わせられます。

2) コードだけを静的に確認（AWS認証不要）
- モジュール直下で `terraform validate`/`terraform fmt -check` を実行可能です。
  - 例: `infra/modules/network/endpoint` へ移動して `terraform validate`
- Lint/セキュリティ（任意）: `tflint` や `tfsec`/`checkov` があれば実行してください。

3) 変更プランを確認（AWS認証 必要・非破壊）
- Terragrunt は依存の `mock_outputs` を用意しており、依存を未適用でも `plan` 可能な箇所があります。
- バックエンドはローカルにし、状態S3を作らずにプランだけ見るのを推奨します。
  - 例（単一モジュール）:
    - `cd infra/envs/dev/network/endpoint`
    - `AWS_PROFILE=<your-profile> terragrunt init -backend=false`
    - `AWS_PROFILE=<your-profile> terragrunt plan -lock=false -input=false`
  - 例（dev配下を広くプラン）:
    - `cd infra/envs/dev`
    - `AWS_PROFILE=<your-profile> terragrunt run-all init -backend=false`
    - `AWS_PROFILE=<your-profile> terragrunt run-all plan -lock=false -input=false`

注意:
- `infra/envs/dev/_common.hcl` で `get_aws_account_id()` を参照しているため、TerragruntコマンドはAWS認証情報が必要です（プランでも）。
- `plan` は非破壊ですが、VPC Endpointなどは実適用するとコストが発生します。`apply` は行わないでください。

## 実適用について（基本は不要・非推奨）

- 採用・レビュー目的での `apply` は想定していません。特に `infra/organization/**` は Organizations/SSO/アカウント作成を伴い、強い権限と費用が必要です。
- それでも自己責任で最小限の実適用を試す場合:
  1. まず `infra/organization/state_backend` を使って状態管理用S3を自分のアカウントに作成（直Terraform）
  2. `infra/envs/dev/_remote_state.hcl` の `bucket` 名を自分のS3に合わせて変更
  3. 必要な最小モジュールのみを Terragrunt で `apply`（強く非推奨）

強い注意:
- `infra/organization/organizations` 配下は実組織やメールアドレス、OU ID をハードコードしており、第三者アカウントでの適用は現実的ではありません。
- Security/Config/GuardDuty/SecurityHub/CloudTrail などセキュリティ系は無料ではなく、VPC/Endpoint/Route53 も費用がかかります。
- `apply` は本当に必要な場合のみ、ご自身の検証アカウントで、影響範囲を最小化して行ってください。`destroy` 手順・上限予算・タグ運用・`prevent_destroy` 等のガードレールを設定することを推奨します。

## リポジトリ構成の目安

- `infra/modules/**`: 再利用可能なTerraformモジュール群
- `infra/envs/dev/**`: Terragrunt による環境スタック（依存の `mock_outputs` を一部用意）
- `infra/organization/**`: 組織・SSO・委任などアカウント横断の初期セットアップ（直Terraform）

## 追加メモ

- CIで回す場合の一例（参考）:
  - `terraform fmt -check -recursive`
  - `tflint --recursive`
  - `tfsec` または `checkov`
  - `terragrunt run-all validate`（AWS認証が必要な箇所に注意）
- 評価者向けには、上記 Quick Start の「静的確認」か「planのみ」を見ていただければ十分に意図が伝わる想定です。
