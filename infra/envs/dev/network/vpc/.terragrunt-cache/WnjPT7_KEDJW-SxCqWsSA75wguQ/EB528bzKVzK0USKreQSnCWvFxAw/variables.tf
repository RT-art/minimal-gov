###############################################
# Metadata
###############################################
variable "region" {
  type        = string
  description = "AWS region"
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "env" {
  type        = string
  description = "Environment name (dev/stg/prod)"
}

variable "tags" {
  type    = map(string)
  default = {}
}
###############################################
# VPC
###############################################
variable "vpc_cidr" {
  description = "VPC の CIDR ブロック"
  type        = string
}

variable "vpc_name" {
  description = "VPC 名 (Name タグに使われる)"
  type        = string
}

###############################################
# Flow Logs (セキュリティアカウント集約)
###############################################
# variable "security_account_id" {
#   description = "Flow Logs を集約するセキュリティアカウントの ID"
#   type        = string
# }
# 
# variable "log_format" {
#   description = "VPC Flow Logs の出力フォーマット"
#   type        = string
#   default     = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
# }
# 
###############################################
# Subnet
###############################################
variable "subnets" {
  description = "作成するサブネット一覧 (name, cidr, az を指定)"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}