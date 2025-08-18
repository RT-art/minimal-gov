########################################
# inputs
########################################
variable "env" {
  description = "Environment name (dev|stg|prod|sandbox etc.)"
  type        = string
}

variable "app_name" {
  description = "App name for tagging and role naming"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "full_repository" {
  description = "GitHub repository in the form OWNER/REPO"
  type        = string
}

variable "allowed_branches" {
  description = "Branches allowed to assume the role"
  type        = list(string)
  default     = ["main"]
}

variable "managed_policy_arns" {
  description = "Managed policies to attach to the role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

# GitHub OIDC provider params
variable "provider_url" {
  description = "GitHub OIDC provider URL"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "thumbprints" {
  description = "Thumbprints for the OIDC provider"
  type        = list(string)
  # 注意: 将来変わる可能性はゼロじゃない。変だったらAWSのエラーで気づくやつ
  default = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
