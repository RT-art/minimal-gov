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
# Toggle (plan通す用)
###############################################
variable "enable_ecs" {
  type        = bool
  description = "Whether to create ECS cluster/service resources (set false to allow plan with mocked dependencies)"
  default     = true
}
###############################################
# SG
###############################################
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where ECS service will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks (usually private subnets)"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security Group ID of the ALB that fronts ECS service"
}

variable "security_groups" {
  type        = list(string)
  description = "Optional additional security groups to attach to ECS tasks"
  default     = []
}

variable "alb_target_group_arn" {
  type        = string
  description = "ARN of the ALB Target Group for ECS service"
}

###############################################
# ECS Task / Service
###############################################
variable "container_port" {
  type        = number
  description = "Port on which the container listens"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to run"
  default     = 1
}

variable "task_cpu" {
  type        = number
  description = "CPU units for ECS task (e.g. 256 = 0.25 vCPU)"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "Memory (MiB) for ECS task (e.g. 512 = 0.5GB)"
  default     = 512
}

###############################################
# ECR Image Tagging
###############################################
variable "account_id" {
  type        = string
  description = "AWS account ID hosting the ECR repository"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy (e.g. git commit hash or version)"
}
