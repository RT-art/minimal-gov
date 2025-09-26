# metadata
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
  description = "共通タグ（モジュールに渡す tags で利用）"
  type        = map(string)
  default     = {}
}

# SSO
variable "org_state_bucket" {
  description = "Organizationのtfstateが保存されているバケット名"
  type        = string
}

variable "org_state_key" {
  description = "Organizationのtfstateが保存されているバケットのキー"
  type        = string
}

variable "org_state_region" {
  description = "Organizationのtfstateが保存されているリージョン"
  type        = string
}

variable "user_id" {
  description = "Identity Center ユーザーID"
  type        = string
}

variable "assigned_accounts" {
  type        = set(string)
  description = "管理権限セットを付与する論理アカウント名（例: dev, network, security）"
}
