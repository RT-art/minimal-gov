# Metadata
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

# Organization
variable "security_account_email" {
  description = "Security アカウントのメール（未使用メールアドレスを必ず指定）"
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
  description = "Security アカウントを委任管理者に登録するサービスプリンシパル"
  type        = set(string)
  default = [
    "guardduty.amazonaws.com",
    "config.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "securityhub.amazonaws.com",
  ]
}

variable "enabled_policy_types" {
  description = "有効化するポリシー種別（通常は SERVICE_CONTROL_POLICY のみでOK）"
  type        = set(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

# -----------------------------
# OU structure (tfvars から直感的に指定)
# -----------------------------
variable "ou_root" {
  description = "Root OU 名の一覧"
  type        = list(string)
  default     = ["Security", "Workloads", "Sandbox", "Suspended"]
}

variable "ou_children" {
  description = "親 OU 名 => 子 OU 名リスト のマップ"
  type        = map(list(string))
  default     = {
    Workloads = ["Prod", "Dev"]
  }
}

# 重要OUの名前（SCP やアカウント配置に利用）
variable "security_ou_name"  {
  type    = string
  default = "Security"
}
variable "workloads_ou_name" {
  type    = string
  default = "Workloads"
}
variable "prod_ou_name"      {
  type    = string
  default = "Prod"
}
variable "dev_ou_name"       {
  type    = string
  default = "Dev"
}
variable "sandbox_ou_name"   {
  type    = string
  default = "Sandbox"
}
variable "suspended_ou_name" {
  type    = string
  default = "Suspended"
}
