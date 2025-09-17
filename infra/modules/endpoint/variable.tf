variable "vpc_id" {
  description = "VPC ID where endpoints will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for interface endpoints"
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "Route table IDs for gateway endpoints"
  type        = list(string)
  default     = []
}

variable "endpoints" {
  description = "Map of endpoints to create"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
