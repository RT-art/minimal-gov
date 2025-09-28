###############################################
# メタデータ
###############################################
variable "region" {
  type        = string
  description = "このモジュールを適用するAWSリージョン"
}

variable "app_name" {
  type        = string
  description = "組織横断ログ基盤のシステム名"
}

variable "env" {
  type        = string
  description = "環境識別子 (dev/stg/prodなど)"
}

variable "tags" {
  type        = map(string)
  description = "共通で付与するタグの追加セット"
  default     = {}
}

###############################################
# ロググループ基本設定
###############################################
variable "default_retention_in_days" {
  type        = number
  description = "全ロググループに対して標準で適用する保持期間 (日数)。個別指定があればそちらを優先"
  default     = null
}

variable "default_kms_key_arn" {
  type        = string
  description = "全ロググループに共通利用するKMSキーARN。個別指定があればそちらを優先"
  default     = null
}

variable "default_log_group_class" {
  type        = string
  description = "標準クラス(Standard/Inference)などを指定する場合のデフォルト値"
  default     = null
}

variable "log_groups" {
  description = <<EOT
作成するCloudWatch Logsグループの定義。キーは論理名で、以下のプロパティを受け付けます。
- name: 省略時は /aws/<env>/<app_name>/<論理名> 形式で自動生成
- retention_in_days: 個別の保持期間
- kms_key_arn: 個別の暗号化キー
- log_group_class: 標準 or Infrequent Access 等
- skip_destroy: trueで削除を抑止
- tags: 個別タグ
- subscription_filter: 中央集約先(Kinesis Firehose等)へ転送する場合の設定
EOT
  type = map(object({
    name              = optional(string)
    retention_in_days = optional(number)
    kms_key_arn       = optional(string)
    log_group_class   = optional(string)
    skip_destroy      = optional(bool)
    tags              = optional(map(string))
    subscription_filter = optional(object({
      name            = string
      destination_arn = string
      filter_pattern  = string
      role_arn        = optional(string)
      distribution    = optional(string)
    }))
  }))
  default = {}
}

###############################################
# リソースポリシー
###############################################
variable "resource_policies" {
  description = <<EOT
CloudWatch Logsリソースポリシーの集合。組織アカウントからのアクセス許可などをJSON文字列で指定。
キーが policy_name に対応し、値は policy_document のみを持つobject。
EOT
  type = map(object({
    policy_document = string
  }))
  default = {}
}
