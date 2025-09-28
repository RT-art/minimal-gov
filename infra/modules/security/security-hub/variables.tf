###############################################
# Metadata
###############################################
variable "enabled" {
  description = "Toggle to disable the module without removing configuration"
  type        = bool
  default     = true
}

variable "app_name" {
  type        = string
  description = "Application name"
  type        = string
}

variable "env" {
  type        = string
  description = "Environment name (dev/stg/prod)"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

###############################################
# Organizations
###############################################
variable "enable_organization_admin" {
  description = "Create AWS Organizations delegated admin configuration for Security Hub"
  type        = bool
  default     = true
}

variable "delegated_admin_account_id" {
  description = "Explicit AWS account ID to register as the Security Hub delegated administrator"
  type        = string
  default     = null
}

variable "organization_auto_enable" {
  description = "Automatically enable Security Hub for new organization member accounts"
  type        = bool
  default     = true
}

variable "organization_auto_enable_standards" {
  description = "Auto-enable default Security Hub standards for new member accounts (DEFAULT or NONE)"
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "NONE"], upper(var.organization_auto_enable_standards))
    error_message = "organization_auto_enable_standards には DEFAULT もしくは NONE を指定してください。"
  }
}

variable "organization_configuration_type" {
  description = "Security Hub organization configuration mode (LOCAL or CENTRAL)"
  type        = string
  default     = "LOCAL"

  validation {
    condition     = contains(["LOCAL", "CENTRAL"], upper(var.organization_configuration_type))
    error_message = "organization_configuration_type には LOCAL もしくは CENTRAL を指定してください。"
  }

  validation {
    condition = !var.enable_organization_admin || upper(var.organization_configuration_type) != "CENTRAL" || (
      var.finding_aggregator_enabled &&
      var.organization_auto_enable == false &&
      upper(var.organization_auto_enable_standards) == "NONE"
    )
    error_message = "CENTRAL モードを利用する場合は finding_aggregator_enabled=true、organization_auto_enable=false、organization_auto_enable_standards=\"NONE\" としてください。"
  }
}

###############################################
# Security Hub
###############################################
variable "enable_default_standards" {
  description = "Enable the AWS Security Hub default standards"
  type        = bool
  default     = true
}

variable "enabled_standards" {
  description = "Additional Security Hub standards to enable (list of standards ARNs or identifiers)"
  type        = list(string)
  default     = []
}

variable "create_sns_topic" {
  description = "Create a dedicated SNS topic for Security Hub findings notifications"
  type        = bool
  default     = false
}

variable "subscribers" {
  description = "SNS subscription configuration map used when create_sns_topic is true"
  type = map(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
  }))
  default = {}
}

variable "imported_findings_notification_arn" {
  description = "Existing SNS topic ARN for Security Hub findings notifications"
  type        = string
  default     = null
}

variable "cloudwatch_event_rule_pattern_detail_type" {
  description = "Custom CloudWatch Event detail-type used for findings notifications"
  type        = string
  default     = "Security Hub Findings - Imported"
}

###############################################
# Finding Aggregator
###############################################
variable "finding_aggregator_enabled" {
  description = "Create a Security Hub finding aggregator"
  type        = bool
  default     = true
}

variable "finding_aggregator_linking_mode" {
  description = "Linking mode for the finding aggregator (ALL_REGIONS, ALL_REGIONS_EXCEPT_SPECIFIED, SPECIFIED_REGIONS, NO_REGIONS)"
  type        = string
  default     = "ALL_REGIONS"

  validation {
    condition     = contains(["ALL_REGIONS", "ALL_REGIONS_EXCEPT_SPECIFIED", "SPECIFIED_REGIONS", "NO_REGIONS"], var.finding_aggregator_linking_mode)
    error_message = "finding_aggregator_linking_mode には ALL_REGIONS / ALL_REGIONS_EXCEPT_SPECIFIED / SPECIFIED_REGIONS / NO_REGIONS のいずれかを指定してください。"
  }
}

variable "finding_aggregator_regions" {
  description = "Region list used when aggregator linking mode requires explicit configuration"
  type        = list(string)
  default     = []

  validation {
    condition = !var.finding_aggregator_enabled || !contains([
      "ALL_REGIONS_EXCEPT_SPECIFIED",
      "SPECIFIED_REGIONS",
    ], var.finding_aggregator_linking_mode) || length(var.finding_aggregator_regions) > 0
    error_message = "ALL_REGIONS_EXCEPT_SPECIFIED もしくは SPECIFIED_REGIONS を選択した場合、finding_aggregator_regions に 1 つ以上のリージョンを指定してください。"
  }
}
