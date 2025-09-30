# Metadata
variable "env" {
  type = string
}

variable "app_name" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Organization
variable "enabled_policy_types" {
  description = "なんのポリシー(scp、tagポリシー等)を有効化するか"
  type        = list(string)
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
variable "additional_ous" {
  description = "追加で作成したいOUのマップ。keyがOU名、valueが親OU名"
  type = map(object({
    parent_ou = string # 親OU名。指定されなければrootにぶら下げる
  }))
  default = {}
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
  type = map(object({
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

# scp
variable "add_scps" {
  description = "追加で作成・アタッチする SCP の一覧"
  type = map(object({
    description   = string
    file          = string           # applyした時の/policies/以下のファイル名
    target_id     = optional(string) # 直接 OU / Account ID を指定する場合
    target_ou_key = optional(string) # module.organizations.ou_ids のキーを利用する場合
  }))
  default = {}

  validation {
    condition = alltrue([
      for scp in values(var.add_scps) :
      (try(scp.target_id, null) != null) || (try(scp.target_ou_key, null) != null)
    ])
    error_message = "各 SCP には target_id か target_ou_key のいずれかを指定してください。"
  }
}
