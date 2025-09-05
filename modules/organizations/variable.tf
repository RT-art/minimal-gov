# AWS Organization本体作成
variable "enabled_policy_types" {
  description = "なんのポリシー(scp、tagポリシー等)を有効化するか"
  type    = list(string)
  default = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

variable "aws_service_access_principals" {
  description = "サービスアクセスを有効化するリソース指定（guardduty,configなど、組織内で一元管理したいリソース）"
  type        = list(string)
  default = [
    "guardduty.amazonaws.com",
    "config.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "securityhub.amazonaws.com",
    # 必要に応じて追加
  ]
}

# OU作成
variable "tags" {
  type = map(string)
}

# Securityアカウント作成
variable "security_account_name" {
  type    = string
  default = "Security"
}

variable "security_account_email" {
  type = string
}

# メンバーアカウント作成
variable "member_accounts" {
  type    = map(object({
    name  = string
    email = string
    ou    = string
    tags  = string 
  }))
}

# Securityアカウントを委任管理者に登録
variable "delegated_services" {
  description = "Securityアカウントを委任管理者に登録するサービス"
  type        = set(string)
}

