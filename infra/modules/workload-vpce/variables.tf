###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "vpc_id" {
  type        = string
  description = <<-EOT
  既存 VPC の ID。すべての VPC エンドポイントはこの VPC 内に作成されます。
  例: "vpc-0123456789abcdef0"
  EOT
}

variable "subnet_ids" {
  type        = list(string)
  description = <<-EOT
  Interface 型 VPC エンドポイントを配置するプライベートサブネットの ID 一覧。
  各サブネットに関連付くルートテーブルを自動取得し、S3 Gateway エンドポイントにも使用します。
  EOT
}

variable "security_group_id" {
  type        = string
  description = <<-EOT
  Interface 型エンドポイントに適用するセキュリティグループの ID。
  VPC 内クライアントからの 443/TCP のみを許可した最小権限 SG を渡すことを推奨します。
  EOT
}

variable "services" {
  type        = list(string)
  default     = []
  description = <<-EOT
  作成する Interface 型 VPC エンドポイントのサービス短縮名一覧。
  未指定または空リストの場合、デフォルトで以下を作成します。
    - ecr.api
    - ecr.dkr
    - secretsmanager
    - logs
  例: ["ecr.api", "ecr.dkr", "secretsmanager", "logs"]
  必要に応じて追加・削除してください。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  追加で付与するタグのマップ。コンプライアンスやコスト配賦のため、
  Project や Env などのタグ付与を推奨します。
  EOT
}
