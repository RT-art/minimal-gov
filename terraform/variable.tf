variable "vpc_cidr_block" {
  type        = string
  description = "VPCのCIDRブロック"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block"{
    type = strung
    description = "サブネットのCIDRブロック"
    default =  "10.0.0.0/24"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone"
  default     = "ap-northeast-1a"
}

variable "instance_type" {
  type        = string
  description = "EC2インスタンスタイプ"
  default     = "t2.micro"
}

variable "ami_name_filter" {
  type        = string
  description = "Amazon Linux 2023 AMIの名前フィルター"
  default     = "al2023-ami-*-x86_64"
}

variable "instance_key_name" {
  type        = string
  description = "EC2インスタンスのキーペア名"
  default     = "ec2-practice-docker" 
}

variable "docker_image_name" {
  type        = string
  description = "Dockerイメージ名"
  default     = "rtart/my-app:latest"
}