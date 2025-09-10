###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "env" {
  type        = string
  description = "デプロイ対象の環境名 (例: dev, prod)。provider の default_tags に反映されます。"
}

variable "app_name" {
  type        = string
  description = "アプリケーション名。タグ Application に利用されます。"
}

variable "region" {
  type        = string
  description = "AWS リージョン。provider の region に利用します。"
}

variable "name" {
  type        = string
  description = <<-EOT
  作成する ECR リポジトリ名。
  例: "app" を指定すると "app" というリポジトリが作成されます。
  EOT
}

variable "keep_last_images" {
  type        = number
  default     = 10
  description = <<-EOT
  ライフサイクルポリシーで保持する最新イメージ数。
  指定した数を超える古いイメージは自動削除されます。
  EOT
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = <<-EOT
  ECR リポジトリの暗号化に使用する KMS キーの ARN。
  未指定の場合は AWS 管理キー (alias/aws/ecr) が自動的に利用されます。
  EOT
}

variable "pull_principal_arns" {
  type        = list(string)
  default     = []
  description = <<-EOT
  このリポジトリからイメージを pull できる IAM プリンシパルの ARN 一覧。
  複数アカウントからの利用を想定する場合に指定してください。
  空のままにするとクロスアカウントアクセスは付与されません。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  追加で付与する任意のタグ。
  provider で設定される default_tags に加えてマージされます。
  EOT
}

