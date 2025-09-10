###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "env" {
  type        = string
  description = "デプロイ対象の環境名 (例: dev, prod)。タグ付与およびリソース名に利用します。"
}

variable "app_name" {
  type        = string
  description = "アプリケーション名。provider の default_tags に設定されます。"
}

variable "region" {
  type        = string
  description = "AWS リージョン。provider 設定およびタグに利用します。"
}

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  リソースの論理名や Name タグに付与するプレフィックス。
  未指定（null/空文字）の場合は "vpn" を用います。
  EOT
}

variable "customer_gateway_ip" {
  type        = string
  description = <<-EOT
  オンプレミス側 VPN デバイスのパブリック IP アドレス。
  例: "203.0.113.1"。
  EOT

  validation {
    # cidrhost を用いることで IPv4 形式か簡易チェック
    condition     = can(cidrhost("${var.customer_gateway_ip}/32", 0))
    error_message = "customer_gateway_ip は有効な IPv4 形式で指定してください。"
  }
}

variable "customer_gateway_bgp_asn" {
  type        = number
  description = <<-EOT
  オンプレミス側の BGP ASN。静的ルーティングのみを利用する場合でも必須です。
  一般的には 64512-65534 のプライベート ASN を指定します。
  EOT

  validation {
    condition     = var.customer_gateway_bgp_asn > 0 && var.customer_gateway_bgp_asn < 4294967295
    error_message = "customer_gateway_bgp_asn は 1 以上 4294967294 以下の数値で指定してください。"
  }
}

variable "transit_gateway_id" {
  type        = string
  description = "接続先となる Transit Gateway の ID (例: tgw-xxxxxxxxxxxxxxxxx)。"

  validation {
    condition     = length(var.transit_gateway_id) > 4 && substr(var.transit_gateway_id, 0, 4) == "tgw-"
    error_message = "transit_gateway_id は 'tgw-' で始まる有効な ID を指定してください。"
  }
}

variable "vpn_static_routes" {
  type        = list(string)
  default     = []
  description = <<-EOT
  VPN 接続に追加する静的ルートの CIDR ブロック一覧。
  例: ["10.0.0.0/16", "10.2.0.0/16"]
  EOT

  validation {
    condition     = alltrue([for cidr in var.vpn_static_routes : can(cidrnetmask(cidr))])
    error_message = "vpn_static_routes の各要素は有効な CIDR 形式で指定してください。"
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "追加で付与する任意のタグ。provider の default_tags とマージされます。"
}

