###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name" {
  type        = string
  default     = null
  description = <<-EOT
  アタッチメントの Name タグに用いる論理名。未指定の場合は "tgw-vpc-attachment" を使用します。
  複数のアタッチメントを運用する場合の識別に役立ちます。
  例: "dev-spoke-a" など。
  EOT
}

variable "transit_gateway_id" {
  type        = string
  description = <<-EOT
  接続先の Transit Gateway の ID（例: tgw-xxxxxxxx）。
  modules/tgw-hub の出力 `tgw_id` を渡すのが典型です。
  EOT
}

variable "vpc_id" {
  type        = string
  description = <<-EOT
  接続元 VPC の ID（例: vpc-xxxxxxxx）。
  modules/vpc-spoke の出力 `vpc_id` を渡すのが典型です。
  EOT
}

variable "subnet_ids" {
  type        = list(string)
  description = <<-EOT
  VPC アタッチメントに使用するサブネット IDs のリスト。
  冗長性のため、異なる AZ のサブネットを最低 2 つ以上指定することを推奨します。
  例: ["subnet-aaaa", "subnet-bbbb"]
  EOT

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "subnet_ids は 1 つ以上のサブネット ID を指定してください（推奨: 異なる AZ で 2 つ以上）。"
  }
}

variable "dns_support" {
  type        = string
  default     = "enable"
  description = <<-EOT
  DNS サポート（enable/disable）。VPC 内名解決を TGW 越しに行う一般的なユースケースでは enable を推奨します。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.dns_support)
    error_message = "dns_support は 'enable' または 'disable' を指定してください。"
  }
}

variable "ipv6_support" {
  type        = string
  default     = "disable"
  description = <<-EOT
  IPv6 サポート（enable/disable）。環境で IPv6 を使用する場合のみ enable を選択します。
  既定では disable（保守的なデフォルト）。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.ipv6_support)
    error_message = "ipv6_support は 'enable' または 'disable' を指定してください。"
  }
}

variable "appliance_mode_support" {
  type        = string
  default     = "disable"
  description = <<-EOT
  アプライアンスモード（enable/disable）。FW アプライアンス等の特殊用途で必要となる場合に限り enable。
  既定では disable。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.appliance_mode_support)
    error_message = "appliance_mode_support は 'enable' または 'disable' を指定してください。"
  }
}

variable "transit_gateway_default_route_table_association" {
  type        = string
  default     = "disable"
  description = <<-EOT
  新規アタッチメントを TGW の既定ルートテーブルに自動関連付けするか（enable/disable）。
  経路設計の明確化のため disable を既定とします。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.transit_gateway_default_route_table_association)
    error_message = "transit_gateway_default_route_table_association は 'enable' または 'disable' を指定してください。"
  }
}

variable "transit_gateway_default_route_table_propagation" {
  type        = string
  default     = "disable"
  description = <<-EOT
  新規アタッチメントの経路を TGW 既定 RT に自動伝播するか（enable/disable）。
  意図しない経路流入を避けるため disable を既定とします。
  EOT

  validation {
    condition     = contains(["enable", "disable"], var.transit_gateway_default_route_table_propagation)
    error_message = "transit_gateway_default_route_table_propagation は 'enable' または 'disable' を指定してください。"
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  共通タグ。コンプライアンス/運用の観点から、Project/Env/Owner などの付与を推奨します。
  EOT
}

