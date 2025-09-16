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

###############################################
# Transit Gateway Route Tables
###############################################
variable "route_tables" {
  type = map(object({
    name = string
  }))
  default = {}
}

variable "route_table_associations" {
  type = map(object({
    vpc         = string
    route_table = string
  }))
  default = {}
}

variable "route_table_propagations" {
  type = map(object({
    vpc         = string
    route_table = string
  }))
  default = {}
}

###############################################
#  Route Table Association / Propagation 
###############################################
variable "tgw_attachment_ids" {
  type    = map(string)
  default = {}
}

variable "tgw_route_table_ids" {
  type    = map(string)
  default = {}
}

###############################################
# AWS RAM
###############################################
variable "ram_share_name" {
  description = "Name of the RAM Resource Share"
  type        = string
}
