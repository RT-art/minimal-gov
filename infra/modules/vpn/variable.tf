variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "app_name" {
  description = "Application name used for tagging"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID to attach VPN"
  type        = string
}

variable "customer_gateway_ip" {
  description = "On-premises customer gateway public IP"
  type        = string
}

variable "bgp_asn" {
  description = "BGP ASN for Customer Gateway"
  type        = number
  default     = 65000
}
