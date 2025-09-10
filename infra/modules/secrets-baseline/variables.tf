###############################################
# Variables
# すべての変数に詳細な説明とバリデーションを付与します。
###############################################

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  作成するシークレット名や Name タグに付与する任意のプレフィックス。
  未指定（null/空文字）の場合は "secret" を用います。

  例: "app" を指定するとシークレット名は "app-<key>" となります。
  EOT
}

variable "secrets" {
  type        = any
  description = <<-EOT
  作成するシークレットの内容を表すマップ。
  キーがシークレットの論理名、値がシークレットの中身です。
  値はプレーン文字列またはオブジェクト（JSON 化して保存）を混在させて指定できます。

  例:
  {
    db_password = "P@ssw0rd"
    app_config  = {
      username = "user"
      password = "pass"
    }
  }
  EOT

  validation {
    condition     = can(keys(var.secrets)) && length(keys(var.secrets)) > 0
    error_message = "secrets は 1 つ以上の要素を持つ map で指定してください。"
  }
}

variable "enable_rotation" {
  type        = bool
  default     = false
  description = <<-EOT
  シークレットのローテーションを有効化するかどうか。
  true の場合は rotation_lambda_arn を必ず指定してください。
  EOT
}

variable "rotation_days" {
  type        = number
  default     = 30
  description = <<-EOT
  ローテーション間隔（日数）。
  enable_rotation が true の場合にのみ参照されます。
  EOT

  validation {
    condition     = var.rotation_days > 0
    error_message = "rotation_days は 1 以上の数値を指定してください。"
  }
}

variable "rotation_lambda_arn" {
  type        = string
  default     = null
  description = <<-EOT
  シークレットのローテーションを実行する Lambda 関数の ARN。
  enable_rotation が true の場合に必須です。それ以外は未指定でも構いません。
  EOT

  validation {
    condition     = !var.enable_rotation || (var.rotation_lambda_arn != null && var.rotation_lambda_arn != "")
    error_message = "enable_rotation が true の場合、rotation_lambda_arn を指定してください。"
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  すべてのリソースに付与する共通タグ。
  コンプライアンスやコスト配賦のため、Project/Env/Owner 等のタグ付与を推奨します。
  EOT
}

