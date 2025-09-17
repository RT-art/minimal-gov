# ECS Fargate Module

このモジュールは、Fargate 上で動作するシンプルな ECS サービスを構築します。共通メタデータとして環境名やアプリケーション名、任意タグを受け取り、関連リソースに付与します。

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `env` | `string` | yes | 環境名 (例: `dev`, `stg`, `prd`)。タスク定義の環境変数 `ENV` に設定されます。 |
| `app_name` | `string` | yes | アプリケーション名。`Application` タグの値として利用します。 |
| `tags` | `map(string)` | no | 追加で付与するタグ。セキュリティグループや CloudWatch Logs などモジュールが作成するリソースに設定され、`Application`/`Environment` タグに上書きでマージされます。 |
| `service_name` | `string` | yes | ECS サービス名。関連するリソース名のプレフィックスとして利用します。 |
| `container_image` | `string` | yes | タスクで使用するコンテナイメージ。 |
| `container_port` | `number` | yes | コンテナがリッスンするポート番号。 |
| `subnet_ids` | `list(string)` | yes | サービスを配置するサブネット ID の一覧。 |
| `alb_target_group_arn` | `string` | yes | 紐付ける ALB ターゲットグループの ARN。 |
| `security_groups` | `list(string)` | no | 追加で付与するセキュリティグループ ID。 |
| `desired_count` | `number` | no | サービスの希望タスク数。デフォルトは `1`。 |

## Example (Terragrunt)

```hcl
inputs = {
  env      = "dev"
  app_name = "portfolio-app"
  tags = {
    Project     = "minimal-gov"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  service_name         = "portfolio-app"
  container_image      = "123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/portfolio:latest"
  container_port       = 8080
  subnet_ids           = dependency.vpc.outputs.private_subnets
  alb_target_group_arn = dependency.alb.outputs.target_group_arn
  security_groups      = [dependency.rds.outputs.sg_id]
}
```
