###############################################
# Variables
# すべての入力変数に丁寧な説明を付与します。
###############################################

variable "subnet_ids" {
  type        = list(string)
  description = <<-EOT
  Fargate タスクを配置するサブネット ID のリスト。
  通常はプライベートサブネットを指定し、少なくとも 2 つの AZ を含めると可用性が高まります。
  EOT
}

variable "security_group_id" {
  type        = string
  description = <<-EOT
  タスクにアタッチするセキュリティグループ ID。
  DB へのアクセスに必要なインバウンドルールを設定したものを渡してください。
  EOT
}

variable "vpc_id" {
  type        = string
  description = <<-EOT
  上記サブネットおよびセキュリティグループが属する VPC の ID。
  直接参照はしませんが、ドキュメント上の明示のため入力として受け取ります。
  EOT
}

variable "rds_secret_arn" {
  type        = string
  description = <<-EOT
  RDS 接続情報を保持した Secrets Manager シークレットの ARN。
  シークレットは JSON 形式で `username`, `password`, `host`, `port`, `dbname`
  のキーを含んでいる必要があります。
  EOT
}

variable "engine" {
  type        = string
  description = <<-EOT
  ダンプ対象のデータベースエンジン。
  `postgresql` または `mysql` のいずれかを指定してください。
  指定値に応じて使用するコンテナイメージとダンプコマンドが切り替わります。
  EOT

  validation {
    condition     = contains(["postgresql", "mysql"], var.engine)
    error_message = "engine は 'postgresql' か 'mysql' のみ指定可能です。"
  }
}

variable "s3_bucket" {
  type        = string
  description = <<-EOT
  ダンプファイルを保存する既存 S3 バケット名。
  バケット側ではサーバーサイド暗号化 (SSE-KMS など) を有効にしておくことを推奨します。
  EOT
}

variable "s3_prefix" {
  type        = string
  description = <<-EOT
  S3 バケット内での保存プレフィックス (フォルダ相当)。
  末尾にスラッシュを付ける必要はありません。
  EOT
}

variable "schedule_expression" {
  type        = string
  description = <<-EOT
  EventBridge ルールのスケジュール式。
  例: `cron(0 18 * * ? *)` や `rate(1 day)` など。
  EOT
}

variable "task_cpu" {
  type        = number
  description = <<-EOT
  Fargate タスクに割り当てる vCPU 数 (整数)。
  例: 256 (0.25 vCPU)。
  EOT
}

variable "task_memory" {
  type        = number
  description = <<-EOT
  Fargate タスクに割り当てるメモリ量 (MiB)。
  例: 512。
  EOT
}

