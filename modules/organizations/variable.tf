variable "security_account_name" {
  type    = string
  default = "Security"
}

variable "security_account_email" {
  type = string
}

variable "org_admin_role_name" {
  type    = string
  default = "OrganizationAccountAccessRole"
}

variable "allowed_regions" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "delegate_admin_for" {
  description = "Securityアカウントを委任管理者に登録するサービスプリンシパル一覧"
  type        = set(string) # for_each使用の為set
  default     = []
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
    condition = alltrue([
      for v in values(var.member_accounts) : contains(
        concat(
          var.ou_root,
          flatten([
            for parent, children in var.ou_children : [for c in children : "${parent}/${c}"]
          ])
        ),
        v.ou
      )
    ])
    error_message = "member_accounts[*].ou は定義済みの OU（root または parent/child）を指定してください。"
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

# -----------------------------
# Organizational Units (tfvars で直感的に定義)
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
