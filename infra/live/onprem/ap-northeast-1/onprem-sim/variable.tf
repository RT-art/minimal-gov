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
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the simulated on-prem VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet hosting the strongSwan instance"
  type        = string
}

variable "az" {
  description = "Availability zone for the public subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the strongSwan gateway"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for the strongSwan instance"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
  default     = "onprem"
}
