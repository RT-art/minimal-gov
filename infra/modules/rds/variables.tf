###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  リソース名や Name タグに付与する任意のプレフィックス。
  未指定（null/空文字）の場合は "rds" を使用します。
  EOT
}

variable "subnet_ids" {
  type        = list(string)
  description = <<-EOT
  RDS を配置するサブネット ID のリスト。
  異なる AZ に属する最低 2 つのプライベートサブネットを指定してください。
  EOT
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = <<-EOT
  RDS インスタンスに関連付けるセキュリティグループの ID リスト。
  アプリケーションからの接続を許可するルールを事前に設定してください。
  EOT
}

variable "engine" {
  type        = string
  default     = "mysql"
  description = <<-EOT
  利用するデータベースエンジン種別。
  例: "mysql", "postgres", "mariadb" など。
  EOT
}

variable "engine_version" {
  type        = string
  default     = "8.0"
  description = <<-EOT
  データベースエンジンのバージョン。
  固定したいバージョンがある場合に指定します。
  EOT
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = <<-EOT
  RDS インスタンスのクラス。
  小規模用途では db.t3.micro などのバースト系がコスト効率に優れます。
  EOT
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = <<-EOT
  プロビジョニングするストレージ容量 (GiB)。
  多くのエンジンで最小 20GiB が必要です。
  EOT
}

variable "db_name" {
  type        = string
  default     = null
  description = <<-EOT
  初期作成するデータベース名。
  指定しない場合はデータベースを自動作成しません。
  EOT
}

variable "username" {
  type        = string
  description = <<-EOT
  マスターユーザー名。
  機密情報のため、変数ファイルやシークレットマネージャー経由で指定することを推奨します。
  EOT
}

variable "password" {
  type        = string
  sensitive   = true
  description = <<-EOT
  マスターパスワード。
  tfstate に平文で保存されるため、保管場所には十分注意してください。
  EOT
}

variable "multi_az" {
  type        = bool
  default     = false
  description = <<-EOT
  マルチ AZ 配置を有効にするかどうか。
  高可用性が必要な場合に true を指定します。
  EOT
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = <<-EOT
  自動バックアップの保持日数。
  0 を指定するとバックアップを無効化します。
  EOT
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = <<-EOT
  誤削除を防ぐための削除保護を有効にするかどうか。
  本番環境では true を推奨します。
  EOT
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = <<-EOT
  RDS インスタンス削除時に最終スナップショットを取得するかどうか。
  true にするとスナップショットを取得せず即時削除します。
  EOT
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = <<-EOT
  パラメータ変更を即時適用するかどうか。
  false にするとメンテナンスウィンドウまで待機します。
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

