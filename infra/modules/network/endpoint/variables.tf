###############################################
# Metadata
###############################################
variable "region" {
  type        = string
}

variable "app_name" {
  type        = string
}

variable "env" {
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
###############################################
# Endpoint
###############################################
variable "vpc_id" {
  type = string
}

variable "endpoint_subnet_ids" {
  description = "Subnets where Interface endpoints will be placed"
  type        = list(string)
}

variable "route_table_ids" {
  description = "Route tables to associate with Gateway endpoints"
  type        = list(string)
  default     = []
}

variable "endpoints" {
  description = <<EOT
- service (必須): Endpoint名("s3", "ssm", "ecr.api"など)
- service_type (必須): "Interface" or "Gateway"
- private_dns_enabled (オプション, bool)
- policy (オプション, JSON string or map)
- additional_params (オプション, map(any))
EOT

  type = map(object({
    service             = string
    service_type        = string
    private_dns_enabled = optional(bool)
    policy              = optional(any)
    additional_params   = optional(map(any))
  }))
}