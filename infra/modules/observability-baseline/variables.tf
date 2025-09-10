###############################################
# Variables
# すべての入力に詳細な説明を付与します。
###############################################

variable "alb_arn_suffix" {
  type        = string
  description = <<-EOT
  監視対象とする Application Load Balancer の ARN サフィックス。
  例: "app/example/1234567890abcdef"。
  CloudWatch メトリクスの LoadBalancer 次元に使用されます。
  EOT
}

variable "ecs_cluster_name" {
  type        = string
  description = <<-EOT
  監視対象の ECS クラスター名。
  CPU / メモリ利用率アラームおよびダッシュボードの次元に使用されます。
  EOT
}

variable "ecs_service_name" {
  type        = string
  description = <<-EOT
  監視対象の ECS サービス名。
  CPU / メモリ利用率アラームおよびダッシュボードの次元に使用されます。
  EOT
}

variable "rds_identifier" {
  type        = string
  description = <<-EOT
  監視対象の RDS インスタンス識別子 (DBInstanceIdentifier)。
  空きストレージ量と接続数アラームの次元に使用されます。
  EOT
}

variable "sns_topic_arn" {
  type        = string
  default     = null
  description = <<-EOT
  アラーム通知を送信する SNS トピックの ARN。
  指定しない場合、アラームの通知アクションは設定されません。
  EOT
}

variable "alb_5xx_threshold" {
  type        = number
  default     = 1
  description = <<-EOT
  ALB の 5xx エラー数アラームのしきい値。
  1 分間に記録される合計値がこの値を超えるとアラームが発火します。
  EOT
}

variable "ecs_cpu_threshold" {
  type        = number
  default     = 80
  description = <<-EOT
  ECS サービスの CPU 使用率アラームのしきい値 (パーセント)。
  1 分間の平均値がこの値を超えるとアラームが発火します。
  EOT
}

variable "ecs_memory_threshold" {
  type        = number
  default     = 80
  description = <<-EOT
  ECS サービスのメモリ使用率アラームのしきい値 (パーセント)。
  1 分間の平均値がこの値を超えるとアラームが発火します。
  EOT
}

variable "rds_free_storage_threshold" {
  type        = number
  default     = 21474836480
  description = <<-EOT
  RDS の空きストレージ容量アラームのしきい値 (バイト)。
  5 分間の平均値がこの値を下回るとアラームが発火します。
  デフォルトは約 20GB です。
  EOT
}

variable "rds_connections_threshold" {
  type        = number
  default     = 100
  description = <<-EOT
  RDS のデータベース接続数アラームのしきい値。
  5 分間の平均値がこの値を超えるとアラームが発火します。
  EOT
}

variable "dashboard_name" {
  type        = string
  default     = "observability-baseline"
  description = <<-EOT
  作成する CloudWatch ダッシュボードの名前。
  複数環境で併用する場合は一意な名称を指定してください。
  EOT
}

