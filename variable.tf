variable "root_vpc_cidr_block" {
  type        = string
  description = "VPCのCIDRブロック"
}

variable "root_subnet_cidr_block" {
  type        = string
  description = "サブネットのCIDRブロック"
}

variable "root_availability_zone" {
  type        = string
  description = "Availability Zone"
}

variable "root_instance_type" {
  type        = string
  description = "EC2インスタンスタイプ"
}

variable "root_ami_name_filter" {
  type        = string
  description = "Amazon Linux 2023 AMIの名前フィルター"
}

variable "root_instance_key_name" {
  type        = string
  description = "EC2インスタンスのキーペア名"
}

variable "root_docker_image_name" {
  type        = string
  description = "Dockerイメージ名"
}

