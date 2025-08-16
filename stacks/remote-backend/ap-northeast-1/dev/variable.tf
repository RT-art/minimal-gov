########################################
# Metadata
########################################

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

########################################
## S3
########################################

variable "versioning_enabled" {
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state."
  type        = bool
  default     = true
}

variable "server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration."
  type        = any
  default     = {
    rule = [{
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }]
  }
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = true
}