###############################################
# Metadata
###############################################
variable "region" {
  type        = string
  description = "AWS region"
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "env" {
  type        = string
  description = "Environment name (dev/stg/prod)"
}

variable "tags" {
  type    = map(string)
  default = {}
}

###############################################
# CloudTrail
###############################################
variable "enabled" {
  description = "Whether to create the CloudTrail resources"
  type        = bool
  default     = true
}


variable "trail_name" {
  description = "Optional explicit name for the CloudTrail. Defaults to <app_name>-<env>-cloudtrail"
  type        = string
  default     = null
}

###############################################
# Destination
###############################################
variable "s3_bucket_name" {
  description = "S3 bucket that receives CloudTrail logs"
  type        = string
}

variable "s3_key_prefix" {
  description = "Optional prefix inside the destination S3 bucket"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN used to encrypt delivered logs"
  type        = string
  default     = null
}

variable "sns_topic_name" {
  description = "SNS topic name notified on new log delivery"
  type        = string
  default     = null
}

variable "cloudwatch_logs_group_arn" {
  description = "CloudWatch Logs group ARN for log replication"
  type        = string
  default     = null
}

variable "cloudwatch_logs_role_arn" {
  description = "IAM role ARN assumed by CloudTrail for CloudWatch delivery"
  type        = string
  default     = null
}

###############################################
# Trail Behaviour
###############################################
variable "enable_logging" {
  description = "Controls whether CloudTrail delivers events"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enables digest files for log integrity validation"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Record events from all regions"
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Capture events from global services such as IAM"
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Whether this trail is registered as an AWS Organizations trail"
  type        = bool
  default     = true
}

###############################################
# Event Selectors
###############################################
variable "insight_selector" {
  description = "List of insight selector blocks passed to CloudTrail"
  type = list(object({
    insight_type = string
  }))
  default = []
}

variable "event_selector" {
  description = "List of event selector blocks for data event logging"
  type = list(object({
    include_management_events        = bool
    read_write_type                  = string
    exclude_management_event_sources = optional(set(string))

    data_resource = list(object({
      type   = string
      values = list(string)
    }))
  }))
  default = []
}

variable "advanced_event_selector" {
  description = "List of advanced event selector blocks"
  type = list(object({
    name = optional(string)
    field_selector = list(object({
      field           = string
      ends_with       = optional(list(string))
      not_ends_with   = optional(list(string))
      equals          = optional(list(string))
      not_equals      = optional(list(string))
      starts_with     = optional(list(string))
      not_starts_with = optional(list(string))
    }))
  }))
  default = []
}
