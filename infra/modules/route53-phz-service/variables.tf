###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "zone_name" {
  type        = string
  description = <<-EOT
  作成するプライベートホストゾーンの FQDN。
  例: "svc.local" のように末尾にドットを付けない形式で指定します。
  EOT
}

variable "vpc_id" {
  type        = string
  description = <<-EOT
  プライベートホストゾーンを関連付ける VPC の ID。
  この VPC 内のリソースからのみゾーンが解決可能になります。
  EOT
}

variable "records" {
  type = list(object({
    name          = string
    type          = string
    alias_zone_id = string
    alias_name    = string
  }))
  default     = []
  description = <<-EOT
  作成するレコードの一覧。
  各要素は ALIAS レコードを想定しており、ALB や NLB など AWS リソースの
  DNS 名を指し示します。
  - name: サブドメイン名 (例: "api")
  - type: レコードタイプ。主に "A" を想定。
  - alias_zone_id: 参照先リソースのホストゾーン ID
  - alias_name: 参照先リソースの DNS 名
  EOT
}

variable "share_with_account_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
  このプライベートホストゾーンを AWS RAM で共有する先のアカウント ID の一覧。
  空リストの場合、共有は行いません。
  別アカウントの VPC からゾーンを解決させたい場合に指定します。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  追加で付与する共通タグ。
  Provider 側の default_tags に加えて、組織固有の Project や Env などを渡してください。
  EOT
}
