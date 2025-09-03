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


variable "config_aggregator_name" {
  type        = string
  default     = "org-aggregator"
  description = "Name of AWS Config aggregator"
}

variable "config_aggregator_role_name" {
  type        = string
  default     = "AWSConfigAggregatorRole"
  description = "Role name for AWS Config aggregator"
}

variable "trail_name" {
  type        = string
  default     = "org-security-trail"
  description = "Name for the organization CloudTrail"
}

variable "enable_kms_encryption" {
  type        = bool
  default     = false
  description = "Whether to enable KMS encryption for CloudTrail"
}

variable "enable_logging" {
  type        = bool
  default     = true
  description = "Whether to enable CloudTrail logging"
}

variable "guardduty_features" {
  type        = list(string)
  description = "List of GuardDuty features to enable and auto-enable for the organization."
  default = [
    "S3_PROTECTION",
    "RDS_LOGIN_EVENTS",
    "EKS_AUDIT_LOGS",
    "EKS_RUNTIME_MONITORING",
    "LAMBDA_NETWORK_LOGS",
    "EBS_MALWARE_PROTECTION",
  ]
}
