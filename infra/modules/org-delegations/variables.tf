###############################################
# Variables
# Each variable is documented to describe what it controls and why
# it is needed. The goal is to make the module self-explanatory.
###############################################

variable "region" {
  type        = string
  description = <<-EOT
  このモジュールをデプロイする AWS リージョン。
  Provider 設定および default_tags の Region に使用されます。
  EOT
}

variable "app_name" {
  type        = string
  description = <<-EOT
  アプリケーション名。default_tags に設定され、
  組織横断でリソースを識別する助けとなります。
  EOT
}

variable "env" {
  type        = string
  description = <<-EOT
  環境名（例: dev, stg, prd）。default_tags に設定され、
  利用者やコスト配分の識別に役立ちます。
  EOT
}

variable "security_account_id" {
  type        = string
  description = <<-EOT
  セキュリティサービスを一元管理するアカウントの AWS アカウント ID。
  GuardDuty、Security Hub、CloudTrail の各サービスで委任管理者として登録されます。
  EOT
}

variable "enable_guardduty" {
  type        = bool
  default     = true
  description = <<-EOT
  GuardDuty の委任管理者登録を行うかどうか。
  既定値は true で、特別な理由がない限り有効化することを推奨します。
  EOT
}

variable "enable_securityhub" {
  type        = bool
  default     = true
  description = <<-EOT
  Security Hub の委任管理者登録を行うかどうか。
  既定値は true です。無効化したい場合のみ false を指定してください。
  EOT
}

variable "enable_cloudtrail" {
  type        = bool
  default     = true
  description = <<-EOT
  CloudTrail の委任管理者登録を行うかどうか。
  CloudTrail で組織トレイルを管理したい場合は true を維持します。
  EOT
}

