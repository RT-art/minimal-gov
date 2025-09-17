variable "enabled_policy_types" {
  description = "なんのポリシー(scp、tagポリシー等)を有効化するか"
  type        = list(string)
}

variable "aws_service_access_principals" {
  description = "サービスアクセスを有効化するリソース指定（guardduty,configなど、組織内で一元管理したいリソース）"
  type        = list(string)
}

variable "additional_ous" {
  description = "追加で作成したいOUのマップ。keyがOU名、valueが親OU名"
  type = map(object({
    parent_ou = string
  }))
}

variable "security_account_name" {
  type = string
}

variable "security_account_email" {
  type = string
}

variable "member_accounts" {
  type = map(object({
    name  = string
    email = string
    ou    = string
    tags  = string
  }))
}

variable "delegated_services" {
  description = "Securityアカウントを委任管理者に登録するサービス"
  type        = set(string)
}

variable "add_scps" {
  description = "追加で作成・アタッチする SCP の一覧"
  type = map(object({
    description = string
    file        = string
    target_id   = string
  }))
}

variable "tags" {
  type = map(string)
}
