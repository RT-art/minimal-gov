###############################################
# Metadata
###############################################

variable "tags" {
  type    = map(string)
  default = {}
}

variable "name_prefix" {
  type    = string
  default = "tgw"
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
