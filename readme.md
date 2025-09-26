# Minimal Gov

## Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)

![Organization Diagram](./image/Organization.png)

## Versions & Tagging Policy

- Terraform/Provider versions
  - Terraform: `>= 1.9.0, < 2.0.0`（pin: `.terraform-version`）
  - AWS Provider: `~> 6.14`（Terragrunt/直Terraform の両方で統一）
  - Terragrunt: pinned via `.terragrunt-version`

- Terragrunt root 共通化
  - 共有ファイル: `infra/envs/<env>/version.hcl`（`locals.versions` に Terraform/AWS Provider バージョンを定義）
  - 共通変数: `infra/envs/<env>/_common.hcl`（`locals.inputs` に `env`, `app_name`, `region`, `tags` などを定義）
  - 各 `infra/envs/*/root.hcl` は `read_terragrunt_config("version.hcl")` と `read_terragrunt_config("_common.hcl")` を参照し、`generate "versions"` と `inputs` に反映

- タグ規則（基準）
  - ベースタグ: `Project`, `Environment`, `ManagedBy`, `AccountId`
  - 環境: `Environment` は `dev|stg|prod` のいずれか
  - モジュール固有のタグ（例: `Application`, `Region`, など）は各モジュールで上乗せ
  - Terragrunt 共通の `var.tags` を単一ソースとして各モジュールに渡し、リソースで `tags = merge(..., var.tags)` を適用

- Git のタグ／リリース
  - SemVer 準拠（`vX.Y.Z`）。Conventional Commits を推奨
  - 名前空間例: インフラ全体は `infra-vX.Y.Z`、モジュール単位は `module-<name>-vX.Y.Z`

- ECR イメージタグ
  - リリース: `vX.Y.Z` を付与。補助として `main-<shortsha>` や `pr-<num>` を併用可
  - `image_tag_mutability = IMMUTABLE` 前提。ライフサイクルは安定タグ優先で多めに保持

- 推奨ツール/検査
  - `terraform fmt`, `terraform validate`, `tflint`, `terragrunt hclfmt` を pre-commit で実行
  - 変更後は `terraform init -upgrade`（または Terragrunt 経由）で lockfile を更新

## Cost Governance (CUR + Athena)

- マルチアカウントのコスト可視化/分析の標準構成（CUR + Athena + Glue + QuickSight/CID）を追加しました。
- 手順・ベストプラクティス・サンプルSQLは `cost/README.md` と配下SQLを参照してください。
- 既存の IaC に組み込む場合のポイントや改善案もまとめています。
