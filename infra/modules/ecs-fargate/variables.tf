variable "service_name" {
  type        = string
  description = "ECS service name"
}

variable "env" {
  type        = string
  description = "Environment name (e.g. dev, stg, prd)"
}

variable "app_name" {
  type        = string
  description = "Application name for tagging"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to resources"
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
