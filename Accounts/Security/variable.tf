variable "aws_region" {
  description = "AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "org_management_account_id" {
  description = "AWS Organizations の管理アカウント ID（12桁）"
  type        = string
}

variable "tags" {
  description = "共通タグ"
  type        = map(string)
  default = {
    Project   = "org-security"
    ManagedBy = "Terraform"
    Env       = "prod"
  }
}
