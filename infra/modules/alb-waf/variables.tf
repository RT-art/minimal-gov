###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name" {
  type        = string
  description = <<-EOT
  Web ACL および関連リソースの論理名。
  - 例: "dev" を指定すると Web ACL 名は "dev-acl" となります。
  Name タグやメトリクス名にも利用します。
  EOT

  validation {
    condition     = length(var.name) > 0
    error_message = "name は 1 文字以上で指定してください。"
  }
}

variable "allow_cidrs" {
  type        = list(string)
  description = <<-EOT
  アクセスを許可する IPv4 CIDR ブロックの一覧。
  - 例: ["203.0.113.0/24", "198.51.100.10/32"]
  指定された範囲のみ ALLOW とし、それ以外は Block されます。
  EOT

  validation {
    condition     = length(var.allow_cidrs) > 0 && alltrue([for c in var.allow_cidrs : can(cidrnetmask(c))])
    error_message = "allow_cidrs には 1 つ以上の有効な IPv4 CIDR を指定してください。"
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  追加で付与するタグのマップ。
  プロバイダの default_tags とマージされます。
  例: { Project = "minimal-gov", Owner = "network-team" }
  EOT
}

