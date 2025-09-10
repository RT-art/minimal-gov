###############################################
# Variables for vpn-vgw module
###############################################

# VGW をアタッチする対象 VPC の ID
variable "vpc_id" {
  type        = string
  description = "VGW をアタッチする VPC の ID"
}

# オンプレ側のグローバル IP アドレス
# - Customer Gateway の IP として登録されます
variable "customer_gateway_ip" {
  type        = string
  description = "オンプレミス側ゲートウェイのグローバル IP アドレス"
}

# オンプレ側の BGP ASN
# - Customer Gateway の BGP ASN として使用
variable "customer_gateway_bgp_asn" {
  type        = number
  description = "オンプレミス側ゲートウェイの BGP ASN"
}

# VGW 側の Amazon ASN
# - 既定 64512。必要に応じて変更
variable "amazon_side_asn" {
  type        = number
  description = "VGW に割り当てる Amazon 側 ASN"
  default     = 64512
}

# オンプレ側ネットワークへの静的ルート一覧
# - 例: ["10.0.0.0/16", "10.1.0.0/16"]
variable "routes" {
  type        = list(string)
  description = "オンプレミス側宛の CIDR 一覧（静的ルート用）"
  default     = []
}

# VGW の Name タグ
variable "vgw_name" {
  type        = string
  description = "VGW に付与する Name タグ"
  default     = "vgw"
}

# Customer Gateway の Name タグ
variable "cgw_name" {
  type        = string
  description = "Customer Gateway に付与する Name タグ"
  default     = "cgw"
}

# VPN Connection の Name タグ
variable "vpn_connection_name" {
  type        = string
  description = "VPN Connection に付与する Name タグ"
  default     = "vpn-connection"
}

# 追加で付与する共通タグ
variable "tags" {
  type        = map(string)
  description = "リソースへ付与する追加タグ"
  default     = {}
}

