variable "org_name_prefix"        { type = string }
variable "security_account_name"  { type = string }
variable "security_account_email" { type = string }
variable "org_admin_role_name"    { type = string }
variable "allowed_regions"        { type = list(string) }
variable "tags"                   { type = map(string) }
variable "member_accounts" {
  type = map(object({
    email = string
    ou    = string
  }))
  default = {}
}
variable "delegate_admin_for" {
  description = "Securityアカウントを委任管理者に登録するサービスプリンシパル一覧（任意）"
  type        = list(string)
  default     = []
}
