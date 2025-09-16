variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "app_name" {
  description = "Application name used for tagging"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
