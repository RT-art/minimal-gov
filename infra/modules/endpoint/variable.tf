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
}variable "vpc_id" {
  type = string
}

variable "endpoint_subnet_ids" {
  description = "Subnets where Interface endpoints will be placed"
  type        = list(string)
}

variable "route_table_ids" {
  description = "Route tables to associate with Gateway endpoints"
  type        = list(string)
  default     = []
}

variable "endpoints" {
  description = "Definition of VPC endpoints"
  type        = map(any)
}
