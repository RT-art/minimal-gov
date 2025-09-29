variable "region" {
  type        = string
  description = "AWS region"
}

variable "name" {
  type        = string
  description = "Instance name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use (default: latest Amazon Linux 2023)"
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

