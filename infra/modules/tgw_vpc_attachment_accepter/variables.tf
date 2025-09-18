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
# Transit Gateway VPC Attachment Accepter
###############################################
variable "transit_gateway_attachment_id" {
  description = "ID of the TGW VPC attachment to accept"
  type        = string
}

