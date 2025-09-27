###############################################
# Metadata
###############################################
variable "enabled" {
  description = "Whether to create GuardDuty resources"
  type        = bool
  default     = true
}

variable "enable_organization_admin" {
  description = "Enable creation of the AWS Organizations delegated admin configuration"
  type        = bool
  default     = true
}

variable "delegated_admin_account_id" {
  description = "Explicit delegated admin account ID. Defaults to the current account"
  type        = string
  default     = null
}

variable "app_name" {
  description = "Application identifier used for tagging"
  type        = string
}

variable "env" {
  description = "Environment identifier (e.g. dev, stg, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags applied to created resources"
  type        = map(string)
  default     = {}
}

###############################################
# Detector configuration
###############################################
variable "replica_region" {
  description = "Optional AWS region for GuardDuty S3 replica bucket"
  type        = string
  default     = null
}

variable "enable_guardduty" {
  description = "Activate the GuardDuty detector"
  type        = bool
  default     = true
}

variable "enable_s3_protection" {
  description = "Toggle S3 protection data source"
  type        = bool
  default     = true
}

variable "enable_rds_protection" {
  description = "Toggle RDS protection data source"
  type        = bool
  default     = true
}

variable "enable_lambda_protection" {
  description = "Toggle Lambda protection data source"
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Toggle Malware Protection data source"
  type        = bool
  default     = true
}

variable "enable_kubernetes_protection" {
  description = "Toggle Kubernetes audit log protection"
  type        = bool
  default     = true
}

variable "enable_eks_runtime_monitoring" {
  description = "Enable EKS runtime monitoring"
  type        = bool
  default     = true
}

variable "enable_ecs_runtime_monitoring" {
  description = "Enable ECS Fargate runtime monitoring"
  type        = bool
  default     = true
}

variable "enable_ec2_runtime_monitoring" {
  description = "Enable EC2 runtime monitoring"
  type        = bool
  default     = true
}

variable "enable_snapshot_retention" {
  description = "Enable EBS snapshot retention when malware findings occur"
  type        = bool
  default     = false
}

variable "manage_eks_addon" {
  description = "Manage the GuardDuty agent EKS add-on"
  type        = bool
  default     = false
}

variable "manage_ecs_agent" {
  description = "Manage the GuardDuty ECS agent"
  type        = bool
  default     = false
}

variable "manage_ec2_agent" {
  description = "Manage the GuardDuty EC2 agent"
  type        = bool
  default     = false
}

variable "finding_publishing_frequency" {
  description = "Frequency for GuardDuty finding notifications"
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "malware_resource_protection" {
  description = "Resources targeted by malware protection scans"
  type        = list(string)
  default     = []
}

variable "create_malware_protection_role" {
  description = "Create service-linked role for malware protection"
  type        = bool
  default     = false
}

###############################################
# Optional integrations
###############################################
variable "publish_to_s3" {
  description = "Whether to export GuardDuty findings to S3"
  type        = bool
  default     = false
}

variable "guardduty_s3_bucket" {
  description = "Name of an existing GuardDuty findings bucket"
  type        = string
  default     = null
}

variable "guardduty_bucket_acl" {
  description = "Canned ACL applied to the GuardDuty S3 bucket"
  type        = string
  default     = null
}

variable "publishing_config" {
  description = "Publishing destinations for GuardDuty findings"
  type = list(object({
    destination_arn  = string
    kms_key_arn      = string
    destination_type = optional(string)
  }))
  default = [{
    destination_arn  = null
    kms_key_arn      = null
    destination_type = "S3"
  }]
}

variable "filter_config" {
  description = "Optional list of GuardDuty finding filters"
  type = list(object({
    name        = string
    description = optional(string)
    rank        = number
    action      = string
    criterion = list(object({
      field                 = string
      equals                = optional(list(string))
      not_equals            = optional(list(string))
      greater_than          = optional(string)
      greater_than_or_equal = optional(string)
      less_than             = optional(string)
      less_than_or_equal    = optional(string)
    }))
  }))
  default = null
}

variable "ipset_config" {
  description = "Optional GuardDuty IPSet configurations"
  type = list(object({
    activate = bool
    name     = string
    format   = string
    content  = string
    key      = string
  }))
  default = null
}

variable "threatintelset_config" {
  description = "Optional GuardDuty ThreatIntelSet configurations"
  type = list(object({
    activate   = bool
    name       = string
    format     = string
    content    = string
    key        = string
    object_acl = string
  }))
  default = null
}

###############################################
# Organization settings
###############################################
variable "auto_enable_organization_members" {
  description = "Auto-enablement mode for organization member accounts"
  type        = string
  default     = "NEW"
}

variable "auto_enable_org_config" {
  description = "Enable organization-wide auto configuration"
  type        = bool
  default     = null
}
