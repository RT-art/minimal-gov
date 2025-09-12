variable "onprem_cidrs" {
  description = "On-premises CIDRs allowed to query inbound resolver"
  type        = list(string)
}

variable "forward_rules" {
  description = "Forwarding rules for outbound resolver"
  type = list(object({
    domain    = string
    target_ip = string
  }))
  default = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
