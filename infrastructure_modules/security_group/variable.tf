# infrastructure_modules/security_group/variables.tf

variable "sg_name" {
  type        = string
  description = "Name tag for the Security Group."
  default     = "security-group-practice-terraform"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the Security Group will be created."
  # No default, must be provided by composition layer (from network module output)
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks for the ingress rules (HTTP, HTTPS, SSH)."
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "A map of additional tags to assign to the Security Group."
  type        = map(string)
  default     = {}
}