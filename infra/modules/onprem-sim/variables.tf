###############################################
# Variables
# すべての入力変数に詳細な説明を付与しています。
###############################################

variable "vpc_cidr" {
  type        = string
  description = <<-EOT
  VPC に割り当てる CIDR ブロック。
  デモ用オンプレ環境全体のアドレス空間を定義します。
  EOT
}

variable "public_subnet_cidr" {
  type        = string
  description = <<-EOT
  strongSwan インスタンスを配置するパブリックサブネットの CIDR ブロック。
  VPC 内で vpc_cidr と重複しない値を指定してください。
  EOT
}

variable "az" {
  type        = string
  description = <<-EOT
  パブリックサブネットを作成するアベイラビリティゾーン。
  例: ap-northeast-1a
  EOT
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = <<-EOT
  strongSwan 用 EC2 インスタンスのタイプ。
  VPN ゲートウェイとしての基本性能を満たす t3.small を既定値としています。
  EOT
}

variable "ami_id" {
  type        = string
  default     = null
  description = <<-EOT
  strongSwan インスタンスに使用する AMI の ID。
  未指定の場合は最新の Amazon Linux 2023 を自動的に選択します。
  strongSwan がプリインストールされた AMI を利用する場合に指定してください。
  EOT
}

variable "name_prefix" {
  type        = string
  default     = "onprem-sim"
  description = <<-EOT
  作成されるリソース名のプレフィックス。
  複数の環境を同一アカウントで構築する際の識別に利用します。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  追加で付与するタグのマップ。
  Provider の default_tags とマージされます。
  EOT
}

