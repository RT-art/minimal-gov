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

variable "service_name" {
  type        = string
  description = "ECS service name"
}

variable "container_image" {
  type        = string
  description = "Container image for ECS task"
}

variable "container_port" {
  type        = number
  description = "Port number for container"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ECS tasks"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID hosting ECS tasks and security groups"
}

variable "alb_target_group_arn" {
  type        = string
  description = "Target group ARN of the ALB"
}

variable "security_groups" {
  type        = list(string)
  default     = []
  description = "Additional security groups"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "alb_security_group_id" {
  type        = string
  default     = null
  description = "If set, allow ingress to ECS from this ALB SG instead of a wide CIDR"
}
