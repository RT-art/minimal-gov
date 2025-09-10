###############################################
# Variables
# すべての変数に詳細なコメントを付与します。
###############################################

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  リソース名や Name タグに付与する任意のプレフィックス。
  未指定（null/空文字）の場合は "guardduty" を使用します。
  例: "security" を与えると "security-detector" のようなタグになります。
  EOT
}

variable "auto_enable_members" {
  type        = string
  default     = "ALL"
  description = <<-EOT
  Organization 成員アカウントに対して GuardDuty を自動有効化する方法。
  `ALL`  : 既存および新規すべてのメンバーに自動適用。
  `NEW`  : 新規に参加したメンバーのみ自動適用。
  `NONE` : 自動適用しない（上位から個別に有効化が必要）。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  共通タグ。最低限 Project/Env/Owner 等のタグ付与を推奨します。
  EOT
}

