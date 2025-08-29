variable "security_account_name" { type = string }
variable "security_account_email" { type = string }

variable "org_admin_role_name" {
  type    = string
  default = "OrganizationAccountAccessRole"
}

variable "allowed_regions" { type = list(string) }
variable "tags" { type = map(string) }

variable "delegate_admin_for" {
  description = "Securityアカウントを委任管理者に登録するサービスプリンシパル一覧"
  type        = set(string) # for_each使用の為set
  default     = []
}

variable "lock_account_name" {
  description = "true なら name の変更を無視（推奨）"
  type        = bool
  default     = true
}

variable "enabled_policy_types" {
  type    = set(string)
  default = ["SERVICE_CONTROL_POLICY"]
}

variable "member_accounts" {
  type = map(object({
    name  = string
    email = string
    ou    = string
  }))
  default = {}

  validation {
    condition     = alltrue([for v in values(var.member_accounts) : contains(["Security", "Workloads", "Workloads/Prod", "Workloads/Dev", "Sandbox", "Suspended"], v.ou)])
    error_message = "member_accounts[*].ou は定義済みの OU いずれかを指定してください。"
  }
  validation {
    condition     = length(distinct([for v in values(var.member_accounts) : v.email])) == length(values(var.member_accounts))
    error_message = "member_accounts[*].email は一意である必要があります。"
  }
}

variable "delegated_admin_allowlist" {
  description = "Organizations の Delegated Admin に登録可能と確認済みのサービスプリンシパル"
  type        = set(string)
  default = [
    "guardduty.amazonaws.com",
    "config.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "securityhub.amazonaws.com",
    # 必要に応じて追加
  ]
}
