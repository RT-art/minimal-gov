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

variable "zone_name" {
  type        = string
  description = "Route53 private hosted zone name (e.g., dev.internal)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate with the private hosted zone"
}

variable "comment" {
  type        = string
  default     = null
  description = "Optional comment for the hosted zone"
}

