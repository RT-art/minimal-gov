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
# TGW Route
###############################################
variable "route_tables" {
  description = "List of TGW route tables"
  type = list(object({
    name = string
  }))
  default = []
}

variable "route_table_associations" {
  description = "List of TGW associations"
  type = list(object({
    vpc         = string
    route_table = string
  }))
  default = []
}

variable "route_table_propagations" {
  description = "List of TGW propagations"
  type = list(object({
    vpc         = string
    route_table = string
  }))
  default = []
}
