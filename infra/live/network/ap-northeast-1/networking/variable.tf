###############################################
# Metadata
###############################################
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

###############################################
# Transit Gateway
###############################################
variable "description" {
  type        = string
  description = "Description of the Transit Gateway"
  default     = "Transit Gateway"
}

variable "amazon_side_asn" {
  type        = number
  description = "BGP ASN for the Amazon side of the TGW"
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  type        = string
  description = "Whether resource attachments are automatically accepted (enable/disable)"
  default     = "disable"
}

variable "default_route_table_association" {
  type        = string
  description = "Whether to associate attachments to default TGW route table (enable/disable)"
  default     = "disable"
}

variable "default_route_table_propagation" {
  type        = string
  description = "Whether to propagate attachments to default TGW route table (enable/disable)"
  default     = "disable"
}


variable "route_tables" {
  type = map(object({
    name  = string
    scope = string
  }))
}

variable "route_table_associations" {
  type = list(object({
    vpc         = string
    route_table = string
  }))
}

variable "route_table_propagations" {
  type = list(object({
    vpc         = string
    route_table = string
  }))
}

variable "tgw_state" {
  type = object({
    bucket = string
    key    = string
    region = string
  })
}

variable "vpc_state" {
  type = object({
    bucket = string
    key    = string
    region = string
  })
}

variable "ram_principals" { type = set(string) }
variable "ram_share_name" { type = string }
variable "ram_allow_external_principals" { type = bool }


###############################################
# VPC
###############################################
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
}

variable "subnets" {
  description = "List of subnets"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "security_account_id" {
  type        = string
  description = "Security account ID for Flow Logs"
}

variable "log_format" {
  type        = string
  description = "Flow log format"
  default     = "${version} ${account-id} ${interface-id} ${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${start} ${end} ${action} ${log-status}"
}

###############################################
# TGW Attachment
###############################################
variable "tgw_attachment_subnet_names" {
  description = "List of subnet names to use for TGW attachment (one per AZ)"
  type        = list(string)
}

###############################################
# Endpoints
###############################################
variable "endpoints" {
  description = <<EOT
List of VPC endpoints to create.
Example:
endpoints = [
  {
    name         = "ssm"
    service_name = "com.amazonaws.ap-northeast-1.ssm"
    type         = "Interface"
    subnet_names = ["ops-a", "ops-c"]
  },
  {
    name         = "logs"
    service_name = "com.amazonaws.ap-northeast-1.logs"
    type         = "Interface"
    subnet_names = ["ops-a", "ops-c"]
  },
  {
    name         = "s3"
    service_name = "com.amazonaws.ap-northeast-1.s3"
    type         = "Gateway"
  }
]
EOT
  type = list(object({
    name                = string
    service_name        = string
    type                = string # "Interface" or "Gateway"
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, true)
  }))
}

variable "customer_gateway_ip" {
  description = "On-premises customer gateway public IP"
  type        = string
}

variable "customer_gateway_bgp_asn" {
  description = "BGP ASN for the on-premises customer gateway"
  type        = number
  default     = 65000
}