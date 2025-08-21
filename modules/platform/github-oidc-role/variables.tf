variable "provider_url" {
  description = "GitHub OIDC provider URL"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "role_name_prefix" {
  description = "Prefix for IAM role names"
  type        = string
  default     = "GitHubActions-"
}

variable "plan_role_name" {
  description = "Plan role name suffix"
  type        = string
  default     = "TerraformPlan"
}

variable "apply_role_name" {
  description = "Apply role name suffix"
  type        = string
  default     = "TerraformApply"
}

variable "allowed_repositories" {
  description = "List of allowed repositories in the form 'owner/repo'"
  type        = list(string)
}

variable "plan_branches" {
  description = "Branches allowed for plan (refs/heads/*)"
  type        = list(string)
  default     = ["*"]
}

variable "allow_pull_request" {
  description = "Allow plan from pull_request tokens"
  type        = bool
  default     = true
}

variable "apply_branches" {
  description = "Branches allowed for apply (refs/heads/*)"
  type        = list(string)
  default     = ["main"]
}

variable "apply_tag_pattern" {
  description = "Optional tag pattern for apply (e.g. 'v*' -> refs/tags/v*)"
  type        = string
  default     = null
}

variable "plan_managed_policy_arns" {
  description = "Managed policy ARNs to attach to the Plan role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

variable "apply_managed_policy_arns" {
  description = "Managed policy ARNs to attach to the Apply role"
  type        = list(string)
  default     = []
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM roles"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Max session duration in seconds (3600..43200)"
  type        = number
  default     = 3600
}

variable "state_bucket_arn" {
  description = "Optional S3 bucket ARN (or arn:...:bucket/<name>) for tfstate access"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN used for server-side encryption of tfstate"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}
