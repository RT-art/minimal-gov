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

variable "versioning_enabled" {
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state."
  type        = bool
  default     = true
}

variable "use_kms" {
  description = "Use AWS KMS for server-side encryption instead of AES256"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "KMS key ID (if use_kms = true)"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket even if it contains objects."
  type        = bool
  default     = true
}

variable "lifecycle_days" {
  description = "Number of days to keep noncurrent versions of objects"
  type        = number
  default     = 180
}