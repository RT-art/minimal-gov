###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  リソースの論理名や Name タグに付与するプレフィックス。
  未指定（null/空文字）の場合は "vpce" を用います。

  例: "dev" を指定した場合、各エンドポイント名は "dev-<service>" のようになります。
  EOT
}

variable "vpc_id" {
  type        = string
  description = <<-EOT
  既存 VPC の ID。エンドポイントはこの VPC 内に作成されます。
  EOT
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
  インターフェース型 VPC エンドポイントを配置するプライベートサブネットの ID 一覧。
  var.enable_interface_endpoints が true の場合は 1 つ以上を指定してください。
  EOT
}

variable "route_table_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
  ゲートウェイ型 VPC エンドポイント（例: S3）を関連付けるルートテーブル IDs。
  var.enable_gateway_endpoints が true の場合は 1 つ以上を指定してください。
  EOT
}

variable "allowed_cidrs" {
  type        = list(string)
  description = <<-EOT
  エンドポイント用セキュリティグループの許可元 CIDR ブロック一覧。
  一般的には VPC の CIDR（例: ["10.0.0.0/16"]）を指定します。

  注意: 空にすると Interface エンドポイントへの到達性がなくなります。
  セキュリティ最優先のため、明示入力としています。
  EOT

  validation {
    condition     = length(var.allowed_cidrs) > 0
    error_message = "allowed_cidrs は 1 つ以上の CIDR を指定してください (例: [\"10.0.0.0/16\"])."
  }
}

variable "enable_interface_endpoints" {
  type        = bool
  default     = true
  description = <<-EOT
  インターフェース型 VPC エンドポイントを作成するかどうか。
  true の場合は subnet_ids に最低 1 つ以上のサブネットを指定してください。
  EOT
}

variable "enable_gateway_endpoints" {
  type        = bool
  default     = true
  description = <<-EOT
  ゲートウェイ型 VPC エンドポイントを作成するかどうか。
  true の場合は route_table_ids に最低 1 つ以上を指定してください。
  EOT
}

variable "enable_private_dns" {
  type        = bool
  default     = true
  description = <<-EOT
  インターフェース型エンドポイントの Private DNS を有効化するかどうか。
  有効化すると、VPC 内から通常の AWS サービス FQDN で解決可能になります。
  EOT
}

variable "interface_endpoints" {
  type        = list(string)
  default     = [
    # 運用/デプロイ基盤で利用頻度が高いベースライン
    "ssm",           # AWS Systems Manager
    "ssmmessages",   # SSM Agent 用メッセージング
    "ec2messages",   # SSM Agent (EC2) メッセージング
    "logs",          # CloudWatch Logs
    "kms",           # AWS KMS
    "ecr.api",       # Amazon ECR API
    "ecr.dkr",       # Amazon ECR DKR (Docker push/pull)
    "secretsmanager",# AWS Secrets Manager
    "sts",           # AWS STS
  ]
  description = <<-EOT
  作成するインターフェース型 VPC エンドポイントのサービス短縮名一覧。
  例: "ssm" を指定すると "com.amazonaws.<region>.ssm" が作成されます。

  注意: リージョンにより未対応のサービスがある場合は、当該値を除外してください。
  EOT
}

variable "gateway_endpoints" {
  type        = list(string)
  default     = ["s3"]
  description = <<-EOT
  作成するゲートウェイ型 VPC エンドポイントのサービス短縮名一覧。既定は "s3" のみ。
  例: ["s3", "dynamodb"]
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  リソースに付与する共通タグ。コンプライアンスやコスト配賦の観点で、
  最低限 Project/Env/Owner などのタグ付与を推奨します。
  EOT
}

