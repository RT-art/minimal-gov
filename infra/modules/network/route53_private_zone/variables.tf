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
# Route53 PrivateHostZone
###############################################
variable "vpc_id" {
  type        = string
  description = "VPC ID to associate with the private hosted zone"
}

variable "force_destroy" {
  type    = bool
  default = false
}

# レコード定義のリスト
variable "records" {
  type = list(object({
    name   = string
    type   = string               # "A" / "CNAME" / "TXT" など
    ttl    = optional(number)     # alias の場合は不要
    records = optional(list(string))
    alias   = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, true)
    }))
  }))
  default = []
}