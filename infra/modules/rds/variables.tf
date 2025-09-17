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

variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "instance_class" {
  type = string
}

variable "db_name" {
  type = string
}
variable "username" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "allowed_sg_id" {
  type = string
}
