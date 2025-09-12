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

variable "auto_enable_members" {
  description = "Automatically enable member accounts"
  type        = bool
  default     = true
}

variable "enable_afsbp" {
  description = "Subscribe to AWS Foundational Security Best Practices"
  type        = bool
  default     = true
}

variable "linking_mode" {
  description = "Finding aggregation mode"
  type        = string
  default     = "ALL_REGIONS"
}
