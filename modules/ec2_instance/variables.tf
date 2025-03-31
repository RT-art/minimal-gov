variable "module_instance_type" {
  type        = string
  description = "EC2インスタンスタイプ"
}

variable "module_ami_name_filter" {
  type        = string
  description = "Amazon Linux 2023 AMIの名前フィルター"
}

variable "module_instance_key_name" {
  type        = string
  description = "EC2インスタンスのキーペア名"
}

variable "module_docker_image_name" {
  type        = string
  description = "Dockerイメージ名"
}

variable "module_subnet_id" {
  type        = string
  description = "EC2インスタンスを配置するサブネットのID"
}

variable "module_security_group_id" {
  type        = string
  description = "EC2インスタンスに関連付けるセキュリティグループのID"
}

