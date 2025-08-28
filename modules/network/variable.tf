variable "name" {
  description = "リソースのプレフィックス名"
  type        = string
}


variable "vpc_cidr" {
  description = "VPC CIDR (/19 を想定)"
  type        = string
}


variable "az_count" {
  description = "使用する AZ 数"
  type        = number
  default     = 2
}


variable "tags" {
  description = "共通タグ"
  type        = map(string)
  default     = {}
}