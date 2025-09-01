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
    condition     = can(regex("^[a-zA-Z0-9-_]{3,32}$", var.app_name))
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
  type    = map(string)
  default = {}
}

variable "org_management_account_id" {
  description = "AWS Organizations の管理アカウント ID"
  type        = string
}

variable "trail_name" {
  description = "CloudTrail の名前"
  type        = string
}


variable "s3_bucket_name" {
  description = "CloudTrail ログ保存先 S3 バケット名（このモジュールで作成）"
  type        = string
}


variable "is_organization_trail" {
  description = "組織トレイルにするか（管理アカウント or 委任管理から作成が必要）"
  type        = bool
  default     = false
}


variable "multi_region_trail" {
  description = "全リージョン（true）/ 単一リージョン（false）"
  type        = bool
  default     = true
}


variable "enable_kms_encryption" {
  description = "CloudTrail の SSE-KMS 暗号化を有効化するか（true なら kms_key_arn 指定が無ければ KMS を新規作成）"
  type        = bool
  default     = false
}


variable "kms_key_arn" {
  description = "既存 KMS キーの ARN（指定時は新規作成しません）"
  type        = string
  default     = null
}


variable "enable_logging" {
  description = "トレイル作成と同時にロギングを有効化するか"
  type        = bool
  default     = true
}





