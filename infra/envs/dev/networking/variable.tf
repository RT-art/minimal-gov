###############################################
# Metadata
###############################################
variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  type    = string
  default = "tgw"
}

###############################################
# VPC
###############################################
variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "subnets" {
  description = "List of subnets"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "security_account_id" {
  description = "Security account ID"
  type        = string
}

variable "log_format" {
  description = "VPC Flow Log format"
  type        = string
  default     = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
}

###############################################
# Transit Gateway VPC Attachment
###############################################
variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to attach"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the TGW attachment (usually one per AZ)"
  type        = list(string)
}

variable "appliance_mode_support" {
  type    = bool
  default = false
}

variable "transit_gateway_default_route_table_association" {
  type    = bool
  default = false
}

variable "transit_gateway_default_route_table_propagation" {
  type    = bool
  default = false
}

variable "dns_support" {
  type    = bool
  default = true
}

variable "ipv6_support" {
  type    = bool
  default = false
}

###############################################
# Endpoints
###############################################
variable "endpoints" {
  description = "VPC endpoints to create"
  type = list(object({
    name                = string
    service_name        = string
    type                = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, true)
  }))
}
