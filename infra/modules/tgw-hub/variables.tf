###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name" {
  type        = string
  default     = null
  description = <<-EOT
  TGW（および関連タグ）に付与する論理名。未指定の場合は "tgw-hub" を使用します。

  例: "net" を指定すると、TGW の Name タグが "net" となります。
  EOT
}

variable "description" {
  type        = string
  default     = "Minimal Gov TGW Hub"
  description = <<-EOT
  Transit Gateway の説明。変更は動作に影響しませんが、運用時の識別に役立ちます。
  EOT
}

variable "amazon_side_asn" {
  type        = number
  default     = 64512
  description = <<-EOT
  TGW の Amazon 側 ASN。Site-to-Site VPN や Direct Connect の BGP と組み合わせる際に使用します。
  一般的には 64512～65534 のプライベート ASN を用います。
  EOT

  validation {
    condition     = var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534
    error_message = "amazon_side_asn は 64512～65534 の範囲で指定してください。"
  }
}

variable "auto_accept_shared_attachments" {
  type        = string
  default     = "disable"
  description = <<-EOT
  AWS RAM 共有などで他アカウントからのアタッチ要求を自動承認するか（enable/disable）。
  セキュアなデフォルトのため disable を推奨します。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.auto_accept_shared_attachments)
    error_message = "auto_accept_shared_attachments は 'enable' または 'disable' を指定してください。"
  }
}

variable "default_route_table_association" {
  type        = string
  default     = "disable"
  description = <<-EOT
  新しいアタッチメントを既定の RT に自動関連付けするか（enable/disable）。
  意図せぬ経路流入を防ぐため disable を推奨します。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_association)
    error_message = "default_route_table_association は 'enable' または 'disable' を指定してください。"
  }
}

variable "default_route_table_propagation" {
  type        = string
  default     = "disable"
  description = <<-EOT
  新しいアタッチメントの経路伝播を既定の RT に自動有効化するか（enable/disable）。
  経路制御の明確化のため disable を推奨します。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_propagation)
    error_message = "default_route_table_propagation は 'enable' または 'disable' を指定してください。"
  }
}

variable "dns_support" {
  type        = string
  default     = "enable"
  description = <<-EOT
  DNS サポートを有効化するか（enable/disable）。TGW 経由の多くのユースケースで有効化が推奨です。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.dns_support)
    error_message = "dns_support は 'enable' または 'disable' を指定してください。"
  }
}

variable "vpn_ecmp_support" {
  type        = string
  default     = "enable"
  description = <<-EOT
  Site-to-Site VPN で ECMP（Equal-Cost Multi-Path）を有効化するか（enable/disable）。
  通常は可用性向上のため enable を推奨します。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.vpn_ecmp_support)
    error_message = "vpn_ecmp_support は 'enable' または 'disable' を指定してください。"
  }
}

variable "rt_name_user" {
  type        = string
  default     = "tgw-rt-user"
  description = <<-EOT
  ユーザ向けルートテーブルの Name タグ。例: ユーザ拠点 VPN → Prod/Dev のみ許可する用途を想定。
  EOT
}

variable "rt_name_spoke_to_network" {
  type        = string
  default     = "tgw-rt-spoke-to-network"
  description = <<-EOT
  Spoke（Prod/Dev）から Network への復路用ルートテーブルの Name タグ。
  EOT
}

variable "rt_name_network_to_spoke" {
  type        = string
  default     = "tgw-rt-network-to-spoke"
  description = <<-EOT
  Network（踏み台等）から Spoke への往路用ルートテーブルの Name タグ。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  共通タグ。コンプライアンス/コスト配賦の観点で Project/Env/Owner などの付与を推奨します。
  EOT
}

