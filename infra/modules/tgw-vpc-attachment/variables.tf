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

variable "attachment_name" {
  description = "Name tag for the TGW attachment"
  type        = string
}

variable "dns_support" {
  description = "Whether DNS support is enabled for the attachment"
  type        = string
  default     = "enable"
}

variable "ipv6_support" {
  description = "Whether IPv6 support is enabled for the attachment"
  type        = string
  default     = "disable"
}

variable "tags" {
  description = "Additional tags for the TGW attachment"
  type        = map(string)
  default     = {}
}
