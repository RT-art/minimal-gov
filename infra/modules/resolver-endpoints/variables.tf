###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  リソース名や Name タグに付与する任意のプレフィックス。
  未指定（null/空文字）の場合は "resolver" を使用します。
  例: "net" を与えると "net-inbound" / "net-outbound" のような名前になります。
  EOT
}

variable "vpc_id" {
  type        = string
  description = <<-EOT
  既存 VPC の ID。Resolver Endpoints はこの VPC 内のサブネットに配置されます。
  EOT
}

variable "create_inbound" {
  type        = bool
  default     = true
  description = <<-EOT
  Inbound Resolver Endpoint を作成するかどうか。
  オンプレミスや別ネットワークから VPC 内のプライベートホストゾーンを解決させる用途で有効化します。
  EOT
}

variable "create_outbound" {
  type        = bool
  default     = false
  description = <<-EOT
  Outbound Resolver Endpoint を作成するかどうか。
  VPC から外部 DNS（オンプレ/DNS アプライアンス等）へフォワードする場合に有効化します。
  なお、フォワーディングのドメインルール（Resolver rules）はこのモジュールでは作成しません。
  EOT
}

variable "inbound_subnet_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
  Inbound Resolver Endpoint を配置するサブネット ID 一覧。
  高可用性のため、少なくとも 2 つの AZ に跨る 2 個以上のサブネットを推奨します。
  EOT
}

variable "outbound_subnet_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
  Outbound Resolver Endpoint を配置するサブネット ID 一覧。
  高可用性のため、少なくとも 2 つの AZ に跨る 2 個以上のサブネットを推奨します。
  EOT
}

variable "inbound_allowed_cidrs" {
  type        = list(string)
  default     = []
  description = <<-EOT
  Inbound 用セキュリティグループで 53/TCP および 53/UDP を許可する送信元 CIDR の一覧。
  セキュリティ既定値として、未指定（空）の場合は一切許可しません（Inbound 閉鎖）。
  例: オンプレミスからの到達を許す場合は、オンプレの送信元アドレス範囲を指定します。
  EOT
}

variable "security_group_id" {
  type        = string
  default     = null
  description = <<-EOT
  既存のセキュリティグループ ID。指定した場合、このモジュールは SG を新規作成せず、
  ルールの作成も行いません（SG のルール設計を上位で完全に管理する用途向け）。
  未指定（null）の場合は、このモジュールが Resolver 用 SG を 1 つ作成します。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  共通タグ。最低限 Project/Env/Owner 等のタグ付与を推奨します。
  EOT
}

