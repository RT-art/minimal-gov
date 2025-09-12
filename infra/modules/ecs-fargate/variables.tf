###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "service_name" {
  type        = string
  description = <<-EOT
  作成する ECS サービスの名称。
  各種リソース名やタグの接頭辞としても利用されます。
  EOT
}

variable "vpc_id" {
  type        = string
  description = <<-EOT
  ECS サービスおよび ALB を配置する VPC の ID。
  EOT
}

variable "subnet_ids" {
  type        = list(string)
  description = <<-EOT
  サービスおよび ALB が利用するサブネット ID の一覧。
  少なくとも 2 つの AZ を指定してください。
  EOT
}

variable "container_image" {
  type        = string
  description = <<-EOT
  実行するコンテナイメージ。
  例: "public.ecr.aws/nginx/nginx:latest"
  EOT
}

variable "container_port" {
  type        = number
  description = <<-EOT
  コンテナでリッスンするポート番号。
  ALB とターゲットグループも同じポートで動作します。
  EOT
}

variable "desired_count" {
  type        = number
  default     = 1
  description = <<-EOT
  起動するタスク数の希望値。
  運用中に手動でスケールする場合を考慮し、
  terraform 側では変更を無視します。
  EOT
}

variable "task_cpu" {
  type        = number
  description = <<-EOT
  1 タスクあたりに割り当てる CPU 単位。
  例: 256 (0.25vCPU), 512 (0.5vCPU) など。
  EOT
}

variable "task_memory" {
  type        = number
  description = <<-EOT
  1 タスクあたりに割り当てるメモリ (MiB)。
  EOT
}

variable "allowed_cidrs" {
  type        = list(string)
  description = <<-EOT
  ALB へのアクセスを許可する CIDR の一覧。
  社内ネットワークなど必要最小限に絞ってください。
  EOT
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = <<-EOT
  ALB ターゲットグループのヘルスチェックパス。
  アプリケーションで 200 系を返すエンドポイントを指定します。
  EOT
}

variable "waf_acl_arn" {
  type        = string
  default     = null
  description = <<-EOT
  既存の WAFv2 Web ACL の ARN。
  指定した場合、ALB に関連付けて追加保護を行います。
  未指定なら関連付けません。
  EOT
}

variable "secrets" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  コンテナへ渡す Secrets Manager の ARN マップ。
  キーが環境変数名、値がシークレット ARN です。
  EOT
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = <<-EOT
  Fargate タスクにパブリック IP を付与するかどうか。
  既定ではセキュリティを優先して付与しません。
  NAT や VPC エンドポイントが無い環境での動作確認等で
  付与したい場合のみ true に設定してください。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  追加のタグを指定する任意のマップ。
  共通タグは provider の default_tags を利用します。
  EOT
}

