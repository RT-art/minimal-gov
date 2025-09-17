variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "repository_read_write_access_arns" {
  type        = list(string)
  description = "IAM principals (roles/users) to have read/write access"
  default     = []
}
