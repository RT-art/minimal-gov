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
# VPC情報
###############################################
variable "vpc_id" {
  description = "対象のVPC ID"
  type        = string
}

variable "vpc_name" {
  description = "VPC名（SGの名前付けに使用）"
  type        = string
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック（SGのインバウンド許可に使用）"
  type        = string
}

variable "subnets" {
  description = "VPCモジュールから受け取るサブネットのmap（名前→id, cidr, az）"
  type = map(object({
    id   = string
    cidr = string
    az   = string
  }))
}

variable "route_table_id" {
  description = "Gatewayエンドポイントで利用するRoute Table ID"
  type        = string
}

###############################################
# VPC Endpoints定義
###############################################
variable "endpoints" {
  description = <<EOT
作成するVPCエンドポイントのリスト。
- name: 論理名
- service_name: com.amazonaws.ap-northeast-1.ssm など
- type: "Interface" または "Gateway"
- subnet_names: (Interfaceの場合必須) サブネット名のリスト
- private_dns_enabled: (オプション) デフォルトtrue
EOT
  type = list(object({
    name                = string
    service_name        = string
    type                = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, true)
  }))
}

###############################################
# Tags
###############################################
variable "tags" {
  description = "リソース共通タグ"
  type        = map(string)
  default     = {}
}
