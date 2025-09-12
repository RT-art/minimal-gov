variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_name" {
  description = "VPC name (for tagging)"
  type        = string
}

variable "inbound_subnet_ids" {
  description = "Subnets for inbound resolver (at least 2 AZs)"
  type        = list(string)
  default     = []
}

variable "outbound_subnet_ids" {
  description = "Subnets for outbound resolver (at least 2 AZs)"
  type        = list(string)
  default     = []
}

variable "onprem_cidrs" {
  description = "On-premises CIDRs allowed to query inbound resolver"
  type        = list(string)
  default     = []
}

variable "forward_rules" {
  description = <<EOT
Forwarding rules for outbound resolver.
Example:
forward_rules = [
  { domain = "corp.local.", target_ip = "10.0.0.10" },
  { domain = "legacy.local.", target_ip = "10.0.0.20" }
]
EOT
  type = list(object({
    domain    = string
    target_ip = string
  }))
  default = []
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
