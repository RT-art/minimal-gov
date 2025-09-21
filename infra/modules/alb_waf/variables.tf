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


variable "name" {
  type        = string
  description = "Base name for ALB and WAF resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ALB is created"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ALB"
}

variable "allow_cidrs" {
  type        = list(string)
  description = "CIDRs allowed by WAF and ALB SG"
}

variable "listener_port" {
  type        = number
  default     = 80
  description = "Listener port for ALB"
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "Target group health check path"
}
