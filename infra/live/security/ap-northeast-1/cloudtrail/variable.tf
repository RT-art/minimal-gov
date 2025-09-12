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
  description = "Additional tags to merge on top of provider default_tags"
  type        = map(string)
  default     = {}
}

variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket to store CloudTrail logs"
  type        = string
  default     = null
}

variable "use_kms" {
  description = "Encrypt logs with a KMS key"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ID when use_kms is true"
  type        = string
  default     = null
}

variable "enable_logging" {
  description = "Start logging immediately"
  type        = bool
  default     = true
}
