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
  type        = map(string)
  description = "Common tags"
  default     = {}
}

###############################################
# Transit Gateway
###############################################
variable "transit_gateway_id" {
  type        = string
  description = "The ID of the Transit Gateway"
}

variable "tgw_attachment_ids" {
  type        = map(string)
  description = "Map of VPC names to their Transit Gateway attachment IDs"
}

variable "tgw_route_table_ids" {
  type        = map(string)
  description = "Map of Transit Gateway route table names to their IDs"
  default     = {}
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
