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
  default     = "${version} ${account-id} ${interface-id} ${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${start} ${end} ${action} ${log-status}"
}

###############################################
# TGW Attachment
###############################################
variable "transit_gateway_id" {
  description = "Transit Gateway ID"
  type        = string
}

variable "tgw_attachment_subnet_names" {
  description = "Subnet names for TGW attachment"
  type        = list(string)
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
