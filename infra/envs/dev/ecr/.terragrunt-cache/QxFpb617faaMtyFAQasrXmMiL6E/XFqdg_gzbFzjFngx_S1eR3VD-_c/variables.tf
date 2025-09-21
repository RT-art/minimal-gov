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

variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "repository_read_write_access_arns" {
  type        = list(string)
  description = "IAM principals (roles/users) to have read/write access"
  default     = []
}
