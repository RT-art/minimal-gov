###############################################
# Variables
# Detailed descriptions are provided for all inputs.
###############################################

variable "trail_name" {
  type        = string
  description = <<-EOT
  CloudTrail のトレイル名。
  組織全体で一意になるように、わかりやすい名称を指定してください。
  EOT
}

variable "bucket_name" {
  type        = string
  default     = null
  description = <<-EOT
  CloudTrail ログを保存する S3 バケット名。

  未指定の場合は `ct-logs-<アカウントID>-<リージョン>` 形式で自動生成され、
  グローバルに一意な名前となります。
  固定名を使用したい場合は明示的に指定してください。
  EOT
}

variable "region" {
  type        = string
  description = <<-EOT
  バケット名自動生成時に使用するリージョン名。
  `bucket_name` を指定しない場合にのみ参照されます。
  EOT
}

variable "use_kms" {
  type        = bool
  default     = false
  description = <<-EOT
  CloudTrail ログをカスタマー管理型 KMS キーで暗号化するかどうか。
  `true` に設定した場合、kms_key_id に対象キーの ARN または ID を指定する必要があります。
  EOT
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = <<-EOT
  CloudTrail ログ暗号化に使用する KMS キーの ARN または ID。
  use_kms が true の場合にのみ使用されます。
  EOT

  validation {
    condition     = !var.use_kms || (var.use_kms && var.kms_key_id != null && var.kms_key_id != "")
    error_message = "use_kms を true にする場合、kms_key_id を指定してください。"
  }
}

variable "enable_logging" {
  type        = bool
  default     = true
  description = <<-EOT
  作成直後から CloudTrail のログ記録を開始するかどうか。
  一時的に無効化したい場合は false を指定します。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  CloudTrail トレイルに付与するタグのマップ。
  バケットには自動的には伝播しないため、必要に応じて別途タグ付けしてください。
  EOT
}

