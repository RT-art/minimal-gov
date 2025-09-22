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
# Transit Gateway
###############################################
variable "description" {
  type    = string
  default = "Transit Gateway"
}

variable "amazon_side_asn" {
  type    = number
  default = 64512
}

variable "auto_accept_shared_attachments" {
  type    = bool
  default = false
}

variable "default_route_table_association" {
  type    = bool
  default = false
}

variable "default_route_table_propagation" {
  type    = bool
  default = false
}
