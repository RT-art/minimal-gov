variable "management_profile" {
  description = "管理アカウントに接続するためのAWS CLIプロファイル名"
  type        = string
}

variable "management_region" {
  description = "管理用リージョン（Organizationsはグローバルだが便宜上設定）"
  type        = string
  default     = "us-east-1"
}

# module/organizations へ渡す値
variable "org_name_prefix" {
  description = "組織内リソース命名のプレフィックス（任意）"
  type        = string
  default     = "corp"
}

variable "security_account_name" {
  description = "Securityアカウントのアカウント名"
  type        = string
  default     = "Security"
}

variable "security_account_email" {
  description = "Securityアカウントのルートメールアドレス"
  type        = string
}

variable "org_admin_role_name" {
  description = "新規アカウントに自動作成される管理用ロール名"
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "allowed_regions" {
  description = "利用を許可するAWSリージョン一覧（SCPで強制）"
  type        = list(string)
  default     = ["ap-northeast-1", "us-east-1"]
}

variable "tags" {
  description = "共通タグ"
  type        = map(string)
  default     = {
    ManagedBy = "Terraform"
    Project   = "AWS-Organization"
  }
}

# 将来のメンバーアカウント追加用（現状は空でOK）
variable "member_accounts" {
  description = <<EOT
将来追加するメンバーアカウントの定義。
例:
{
  "SharedServices" = { email = "shared+aws-root@example.com",  ou = "Workloads/Prod" },
  "Sandbox1"       = { email = "sandbox1+aws-root@example.com", ou = "Sandbox" }
}
EOT
  type = map(object({
    email = string
    ou    = string
  }))
  default = {}
}
