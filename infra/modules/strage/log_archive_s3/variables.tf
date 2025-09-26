#############################################
# Metadata
#############################################
variable "region" {
  description = "AWS region where resources are created"
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev/stg/prod)"
  type        = string
}

variable "app_name" {
  description = "Application or workload name used for naming"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}

#############################################
# S3 bucket controls
#############################################
variable "bucket_name" {
  description = "Optional explicit S3 bucket name (must be globally unique). Defaults to <app>-<env>-<account>-log-archive"
  type        = string
  default     = null
}

variable "log_prefix" {
  description = "Prefix under the bucket where CloudTrail writes logs"
  type        = string
  default     = "AWSLogs"
}

variable "force_destroy" {
  description = "Whether to allow bucket deletion even if it contains objects"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

// (Removed) s3_module_version: module version must be static in main.tf

#############################################
# KMS key configuration
#############################################
variable "kms_alias" {
  description = "Optional alias to assign to the KMS key. Defaults to alias/<bucket_name>"
  type        = string
  default     = null
}

variable "kms_description" {
  description = "Optional description for the KMS key"
  type        = string
  default     = null
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period, in days, before KMS key deletion"
  type        = number
  default     = 30
}

variable "kms_admin_arns" {
  description = "Additional IAM principals (ARNs) that can administer the KMS key"
  type        = list(string)
  default     = []
}
