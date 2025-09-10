###############################################
# Variables
# すべての入力変数には詳細な説明を付与しています。
###############################################

variable "permission_set_name" {
  type        = string
  description = <<-EOT
  IAM Identity Center で作成する Permission Set の名称。
  例: "AdministratorAccess" や "ReadOnly" など、利用目的がわかる名前を指定します。
  EOT
}

variable "managed_policy_arns" {
  type        = list(string)
  default     = []
  description = <<-EOT
  Permission Set にアタッチする AWS マネージドポリシーの ARN 一覧。
  例: "arn:aws:iam::aws:policy/AdministratorAccess"。
  空リストの場合、ポリシーは付与されません。
  EOT
}

variable "instance_arn" {
  type        = string
  default     = null
  description = <<-EOT
  対象となる IAM Identity Center インスタンスの ARN。
  通常は自動検出で十分なため、省略可能です。
  複数インスタンスが存在する場合に特定したいときのみ指定します。
  EOT
}

variable "assignments" {
  type = list(object({
    account_id     = string
    principal_type = string
    principal_id   = string
  }))
  default     = []
  description = <<-EOT
  Permission Set を割り当てるアカウントとユーザ/グループの一覧。
  `account_id` は 12 桁の AWS アカウント ID、
  `principal_type` は "USER" または "GROUP" を指定します。
  `principal_id` は IAM Identity Center のユーザ/グループ ID です。
  空リストの場合、割当は作成されません。
  EOT
}

variable "session_duration" {
  type        = string
  default     = "PT8H"
  description = <<-EOT
  Permission Set によるセッションの最大継続時間。
  ISO 8601 形式で指定し、既定は 8 時間 (PT8H) です。
  業務要件に合わせて変更してください。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  Permission Set に付与する任意のタグのマップ。
  組織のタグ基準に従い、必要なキー/値を指定してください。
  EOT
}

