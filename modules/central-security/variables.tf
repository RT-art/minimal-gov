variable "org_management_account_id" {
  description = "AWS Organizations の管理アカウント ID"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
