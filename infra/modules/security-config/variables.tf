###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "env" {
  type        = string
  description = "デプロイ対象の環境名 (例: dev, prod)。タグ付与およびリソース名に利用します。"
}

variable "app_name" {
  type        = string
  description = "アプリケーション名。default_tags の Application に使用します。"
}

variable "region" {
  type        = string
  description = "AWS リージョン。provider 設定およびタグに利用します。"
}

variable "bucket_name" {
  type        = string
  description = <<-EOT
  AWS Config の設定履歴やスナップショットを保存する S3 バケット名。
  create_bucket=true の場合はこの名前でバケットを新規作成します。
  create_bucket=false の場合は既存バケット名を指定してください。
  EOT
}

variable "create_bucket" {
  type        = bool
  default     = true
  description = <<-EOT
  true の場合、上記 bucket_name で S3 バケットを作成します。
  false の場合、既存バケットを利用し新規作成しません。
  EOT
}

variable "aggregator_role_name" {
  type        = string
  default     = "AWSConfigAggregatorRole"
  description = <<-EOT
  Config Aggregator が他アカウントの情報を取得するために Assume する IAM ロール名。
  特別な理由が無い限り既定値のまま利用してください。
  EOT
}

variable "snapshot_delivery_frequency" {
  type        = string
  default     = "TwentyFour_Hours"
  description = <<-EOT
  Config スナップショットを S3 へ配信する頻度。
  有効な値: One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "追加で付与する任意のタグ。provider の default_tags とマージされます。"
}

