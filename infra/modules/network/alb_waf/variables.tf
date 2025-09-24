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
# SG
###############################################
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "ALBを配置するサブネットID"
}

variable "allow_cidrs" {
  type        = list(string)
  description = "ALBリスナーポートへの許可CIDR"
}

variable "listener_port" {
  type        = number
  description = "ALBリスナーポート（例: 80）"
  default     = 80
}

###############################################
# ALB
###############################################
variable "health_check_path" {
  type        = string
  description = "ターゲットグループのヘルスチェックパス"
  default     = "/"
}
