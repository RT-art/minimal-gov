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

variable "enabled" {
  description = "Whether to create Amazon Inspector resources"
  type        = bool
  default     = true
}


variable "name" {
  description = "Logical name segment appended to generated identifiers"
  type        = string
  default     = "inspector"
}

variable "namespace" {
  description = "Optional namespace passed to the underlying Cloud Posse module"
  type        = string
  default     = null
}

variable "stage" {
  description = "Optional stage label passed to the underlying Cloud Posse module"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Additional attributes appended to generated identifiers"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter used when concatenating label elements"
  type        = string
  default     = "-"
}

variable "labels_as_tags" {
  description = "Set of label keys propagated as tags in the Cloud Posse module"
  type        = set(string)
  default     = ["default"]
}

###############################################
# Inspector
###############################################
variable "enabled_rules" {
  description = "List of Amazon Inspector rule groups to enable (e.g. cis, cve, nr, sbp)"
  type        = list(string)
  default     = ["cis", "cve", "sbp"]

  validation {
    condition     = length(var.enabled_rules) > 0
    error_message = "At least one Inspector rule must be specified."
  }
}

variable "schedule_expression" {
  description = "CloudWatch schedule expression controlling Inspector execution cadence"
  type        = string
  default     = "rate(7 days)"
}

variable "event_rule_description" {
  description = "Description applied to the CloudWatch event rule"
  type        = string
  default     = "Trigger recurring Amazon Inspector assessments"
}

variable "assessment_duration" {
  description = "Maximum runtime of the Inspector assessment in seconds"
  type        = string
  default     = "3600"
}

variable "assessment_event_subscription" {
  description = "Notification targets for assessment template events"
  type = map(object({
    event     = string
    topic_arn = string
  }))
  default = {}
}

variable "create_iam_role" {
  description = "Create a dedicated IAM role for CloudWatch Events to start assessments"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN used when create_iam_role is false"
  type        = string
  default     = null
}

###############################################
# Organizations
###############################################
variable "enable_delegated_administrator" {
  description = "Register a delegated administrator for Amazon Inspector via AWS Organizations"
  type        = bool
  default     = false
}

variable "delegated_admin_account_id" {
  description = "Account ID to register as delegated administrator (defaults to caller account)"
  type        = string
  default     = null
}

variable "delegated_admin_service_principal" {
  description = "Service principal used for delegated administrator registration"
  type        = string
  default     = null
}
