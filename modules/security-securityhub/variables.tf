###############################################
# Variables
# すべての変数に詳細なコメントを付与します。
###############################################

variable "auto_enable_members" {
  type        = bool
  default     = true
  description = <<-EOT
  Organization 配下のアカウントに対して Security Hub を自動有効化するかどうか。
  true  を指定すると、既存および新規に参加するすべてのメンバーアカウントで
  Security Hub が自動的に有効になります。
  false の場合は手動で各アカウントを有効化する必要があります。
  EOT
}

variable "enable_afsbp" {
  type        = bool
  default     = true
  description = <<-EOT
  AWS Foundational Security Best Practices (AFSBP) 標準への購読を有効化するかどうか。
  true  の場合、Security Hub の推奨ベースラインチェックを自動で適用します。
  false の場合、標準購読は作成されません。
  EOT
}

variable "linking_mode" {
  type        = string
  default     = "ALL_REGIONS"
  description = <<-EOT
  Finding Aggregator のリンク方法を指定します。
  `ALL_REGIONS` を指定すると、全リージョンのファインディングを集約します。
  特定リージョンのみを対象にする場合は `SPECIFIED_REGIONS` を指定し、
  `regions` 引数を追加で設定します（本モジュールでは未サポート）。
  EOT
}

