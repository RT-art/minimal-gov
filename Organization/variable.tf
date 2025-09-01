variable "env" {
  type = string
  validation {
    condition     = can(regex("^(dev|stg|prod|sandbox)$", var.env))
    error_message = "env は dev|stg|prod|sandbox のいずれか。"
  }
}

variable "app_name" {
  type = string
  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{3,32}$", var.app_name))
    error_message = "app_name は 3–32 文字の英数/ハイフン/アンダースコア。"
  }
}

variable "region" {
  type = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.region))
    error_message = "region の形式が不正。例: ap-northeast-1"
  }
}

variable "tags" {
  description = "共通タグ（provider.default_tags とモジュールに渡す tags の両方で利用）"
  type        = map(string)
  default     = {}
}

variable "security_account_email" {
  description = "Security アカウントのメール（未使用ドメイン/メールを必ず指定）"
  type        = string
}

variable "allowed_regions" {
  description = "利用を許可するリージョン一覧（SCP でそれ以外を拒否）"
  type        = list(string)
}

variable "member_accounts" {
  description = <<EOT
作成するメンバーアカウント一覧。
OU は下記のいずれかを指定：
"Security" | "Workloads" | "Workloads/Prod" | "Workloads/Dev" | "Sandbox" | "Suspended"
EOT
  type = map(object({
    name  = string
    email = string
    ou    = string
  }))
  default = {}
}

variable "security_account_name" {
  description = "Security アカウント名（任意）"
  type        = string
  default     = "Security"
}

variable "org_admin_role_name" {
  description = "作成アカウントに作られる管理ロール名（任意）"
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "delegate_admin_for" {
  description = "Security アカウントを委任管理者に登録するサービスプリンシパル（任意）"
  type        = set(string)
  default     = []
}

variable "enabled_policy_types" {
  description = "有効化するポリシー種別（通常は SERVICE_CONTROL_POLICY のみでOK）"
  type        = set(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

/*
# 必要な場合のみ有効化して main.tf から渡してください
variable "delegated_admin_allowlist" {
  description = "委任管理者に登録可能と確認済みのサービスプリンシパルの許可リスト"
  type        = set(string)
  default = [
    "guardduty.amazonaws.com",
    "config.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "securityhub.amazonaws.com",
  ]
}
*/
