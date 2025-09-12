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

variable "tags" {
  description = "共通タグ (Environment, Owner など)"
  type        = map(string)
  default     = {}
}

###############################################
# Flow Logs (セキュリティアカウント集約)
###############################################
variable "security_account_id" {
  description = "Flow Logs を集約するセキュリティアカウントの ID"
  type        = string
}

variable "log_format" {
  description = "VPC Flow Logs の出力フォーマット"
  type        = string
  default     = "${version} ${account-id} ${interface-id} ${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${start} ${end} ${action} ${log-status}"
}

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

###############################################
# Transit Gateway
###############################################
variable "transit_gateway_id" {
  description = "接続する Transit Gateway の ID"
  type        = string
}
