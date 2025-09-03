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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to all resources"
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
