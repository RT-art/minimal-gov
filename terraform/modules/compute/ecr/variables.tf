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
# ECR
###############################################
variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "repository_encryption_type" {
  description = "ECR repository encryption type. Valid values: AES256 or KMS"
  type        = string
  default     = "AES256"
}

variable "repository_kms_key" {
  description = "KMS key ARN to use when repository_encryption_type is KMS"
  type        = string
  default     = null
}

variable "repository_force_delete" {
  description = "If true, delete the repository even if it contains images. Default is false."
  type        = bool
  default     = false
}

variable "repository_read_access_arns" {
  description = "List of ARNs that should have read-only access to the ECR repository (e.g., CI/CD roles)."
  type        = list(string)
  default     = []
}