variable "vpc_cidr_block" {
  type        = string
  description = "VPCのCIDRブロック"
}

variable "subnet_cidr_block" {
  type        = string
  description = "サブネットのCIDRブロック"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone"
}

variable "instance_type" {
  type        = string
  description = "EC2インスタンスタイプ"
}

variable "ami_name_filter" {
  type        = string
  description = "Amazon Linux 2023 AMIの名前フィルター"
}

variable "instance_key_name" {
  type        = string
  description = "EC2インスタンスのキーペア名"
}

variable "docker_image_name" {
  type        = string
  description = "Dockerイメージ名"
}