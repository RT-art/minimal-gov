variable "trail_name" {
  description = "CloudTrail 名"
  type        = string
}

variable "is_organization_trail" {
  description = "組織トレイルにするか（管理アカウント or 委任管理から作成が必要）"
  type        = bool
  default     = false
}


variable "multi_region_trail" {
  description = "全リージョン（true）/ 単一リージョン（false）"
  type        = bool
  default     = true
}


variable "enable_kms_encryption" {
  description = "CloudTrail の SSE-KMS 暗号化を有効化するか（true なら kms_key_arn 指定が無ければ KMS を新規作成）"
  type        = bool
  default     = false
}


variable "kms_key_arn" {
  description = "既存 KMS キーの ARN（指定時は新規作成しません）"
  type        = string
  default     = null
}


variable "enable_logging" {
  description = "トレイル作成と同時にロギングを有効化するか"
  type        = bool
  default     = true
}


variable "tags" {
  description = "共通タグ"
  type        = map(string)
  default     = {}
}