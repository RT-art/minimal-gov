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

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to TGW resources"
  default     = {}
}

###############################################
# Transit Gateway Route Tables
###############################################
variable "route_tables" {
  type = map(object({
    name  = string
    scope = string
  }))
  description = "Map of TGW route tables (key=logical name, value={name,scope})"
  default     = {}
}

variable "route_table_associations" {
  type = list(object({
    vpc         = string # VPC 論理名 (remote_state outputs のキーに対応)
    route_table = string # TGW route table の論理名
  }))
  description = "List of route table associations (VPC logical name -> TGW route table logical name)"
  default     = []
}

variable "route_table_propagations" {
  type = list(object({
    vpc         = string
    route_table = string
  }))
  description = "List of route table propagations (VPC logical name -> TGW route table logical name)"
  default     = []
}

###############################################
#  Route Table Association / Propagation 
###############################################
variable "tgw_state" {
  type = object({
    bucket = string
    key    = string
    region = string
  })
  description = "Remote state location for TGW (to fetch TGW route table IDs)"
}

variable "vpc_state" {
  type = object({
    bucket = string
    key    = string
    region = string
  })
  description = "Remote state location for VPC (to fetch TGW attachment IDs)"
}

###############################################
# AWS RAM
###############################################
variable "ram_principals" {
  type        = set(string)
  description = "List of principals (AWS account IDs or Org ARNs) to share the TGW with"
  default     = []
}

variable "ram_share_name" {
  type        = string
  description = "Name of the RAM share"
  default     = "tgw-hub-share"
}

variable "ram_allow_external_principals" {
  type        = bool
  description = "Whether to allow sharing with external accounts outside of the organization"
  default     = false
}
