###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  リソース名や Name タグに付与する任意のプレフィックス。
  未指定（null/空文字）の場合は "transfer" を使用します。
  EOT
}

variable "user_name" {
  type        = string
  description = <<-EOT
  SFTP 接続に使用するユーザ名。
  このモジュールでは 1 ユーザのみを作成します。
  EOT
}

variable "ssh_public_key" {
  type        = string
  description = <<-EOT
  上記ユーザに紐付ける SSH 公開鍵。
  一般的な "ssh-rsa" や "ssh-ed25519" 形式で指定してください。
  EOT
}

variable "protocols" {
  type        = list(string)
  default     = ["SFTP"]
  description = <<-EOT
  Transfer Family サーバで有効化するプロトコルの一覧。
  既定では SFTP のみを有効にします。
  例: ["SFTP", "FTPS"]
  EOT
}

variable "endpoint_type" {
  type        = string
  default     = "PUBLIC"
  description = <<-EOT
  サーバのエンドポイント種別。
  "PUBLIC"（インターネット公開）または "VPC" を指定できます。
  最小構成では PUBLIC を既定とします。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  すべてのリソースに付与する共通タグ。
  例: { Project = "minimal-gov", Env = "dev" }
  EOT
}
