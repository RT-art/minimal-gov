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

# VPC settings
variable "vpc_cidr" {
  description = "CIDR block for the network VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_count_per_az" {
  description = "Number of private subnets to create per AZ"
  type        = number
  default     = 2
}

variable "subnet_newbits" {
  description = "Newbits for subnet CIDR calculation"
  type        = number
  default     = 4
}

# Transit Gateway settings
variable "tgw_amazon_side_asn" {
  description = "Amazon side ASN for the Transit Gateway"
  type        = number
  default     = 64512
}

variable "tgw_description" {
  description = "Description for the Transit Gateway"
  type        = string
  default     = "Minimal Gov Transit Gateway"
}

# VPC Endpoints settings
variable "vpce_allowed_cidrs" {
  description = "CIDR blocks allowed to access interface endpoints"
  type        = list(string)
  default     = []
}

variable "interface_endpoints" {
  description = "Interface endpoint services to create"
  type        = list(string)
  default     = []
}

variable "gateway_endpoints" {
  description = "Gateway endpoint services to create"
  type        = list(string)
  default     = []
}
