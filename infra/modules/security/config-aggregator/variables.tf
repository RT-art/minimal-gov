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
# Config Aggregator
###############################################
variable "enabled" {
  description = "Toggle creation of AWS Config aggregation resources"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Optional namespace passed to the Cloud Posse context"
  type        = string
  default     = null
}

variable "stage" {
  description = "Optional stage passed to the Cloud Posse context"
  type        = string
  default     = null
}

variable "context_name" {
  description = "Override for the Cloud Posse label name. Defaults to app_name"
  type        = string
  default     = null
}

variable "context_attributes" {
  description = "Additional attributes injected into the Cloud Posse label context"
  type        = list(string)
  default     = ["security"]
}

variable "context_overrides" {
  description = "Optional map merged into the generated Cloud Posse context"
  type        = map(any)
  default     = {}
}

###############################################
# Config storage
###############################################
variable "config_bucket_name" {
  description = "Bucket name used to store AWS Config history"
  type        = string
}

variable "config_bucket_arn" {
  description = "ARN for the AWS Config history bucket"
  type        = string
}

variable "s3_key_prefix" {
  description = "Prefix within the AWS Config bucket"
  type        = string
  default     = null
}

###############################################
# Aggregation settings
###############################################
variable "global_resource_collector_region" {
  description = "Region that hosts the global AWS Config recorder"
  type        = string
}

variable "central_resource_collector_account_id" {
  description = "Optional account ID that receives AWS Config aggregation"
  type        = string
  default     = null
}

variable "child_account_ids" {
  description = "Account IDs that forward configuration data when not using Organizations"
  type        = list(string)
  default     = []
}

variable "is_organization_aggregator" {
  description = "Enable AWS Organizations wide configuration aggregation"
  type        = bool
  default     = true
}

variable "disabled_aggregation_regions" {
  description = "Regions where config aggregation should be skipped"
  type        = list(string)
  default     = ["ap-northeast-3"]
}

###############################################
# IAM roles
###############################################
variable "create_config_iam_role" {
  description = "Create the IAM role used by the AWS Config recorder"
  type        = bool
  default     = true
}

variable "config_iam_role_arn" {
  description = "Existing IAM role ARN used by the AWS Config recorder"
  type        = string
  default     = null
}

variable "create_organization_aggregator_iam_role" {
  description = "Create the IAM role used by the organization aggregator"
  type        = bool
  default     = true
}

variable "organization_aggregator_iam_role_arn" {
  description = "Existing IAM role ARN used by the organization aggregator"
  type        = string
  default     = null
}

###############################################
# Notifications
###############################################
variable "create_findings_topic" {
  description = "Create an SNS topic for AWS Config compliance notifications"
  type        = bool
  default     = false
}

variable "findings_notification_arn" {
  description = "Existing SNS topic ARN for AWS Config compliance notifications"
  type        = string
  default     = null
}

variable "sns_subscribers" {
  description = "SNS subscription definitions keyed by identifier"
  type        = map(any)
  default     = {}
}

variable "sns_encryption_key_id" {
  description = "KMS key ID used to encrypt the SNS topic"
  type        = string
  default     = null
}

variable "sqs_queue_kms_master_key_id" {
  description = "KMS key ID used to encrypt any subscribed SQS queues"
  type        = string
  default     = null
}

variable "allowed_services_for_findings_topic" {
  description = "AWS service principals allowed to publish to the findings topic"
  type        = list(string)
  default     = []
}

variable "allowed_iam_arns_for_findings_topic" {
  description = "IAM principal ARNs allowed to publish to the findings topic"
  type        = list(string)
  default     = []
}

###############################################
# Optional fine grained settings
###############################################
variable "managed_rules" {
  description = "AWS Config managed rule definitions keyed by name"
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = any
    tags             = map(string)
    enabled          = bool
  }))
  default = {}
}

variable "recording_mode" {
  description = "Optional AWS Config recording mode configuration"
  type = object({
    recording_frequency = string
    recording_mode_override = optional(object({
      description         = string
      recording_frequency = string
      resource_types      = list(string)
    }))
  })
  default = null
}
