###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  リソース名や Name タグに付与する任意のプレフィックス。
  未指定（null/空文字）の場合は "bastion" を使用します。
  EOT
}

variable "subnet_id" {
  type        = string
  description = <<-EOT
  踏み台 EC2 を配置するサブネット ID。
  原則としてプライベートサブネットを指定してください。
  EOT
}

variable "security_group_id" {
  type        = string
  description = <<-EOT
  EC2 インスタンスに適用する既存セキュリティグループの ID。
  SSH/SSM/EIC への必要な許可を事前に設定してください。
  EOT
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = <<-EOT
  起動する EC2 のインスタンスタイプ。
  小規模用途では t3.micro などのバースト系がコスト効率に優れます。
  EOT
}

variable "ami_id" {
  type        = string
  default     = null
  description = <<-EOT
  使用する AMI の ID。
  未指定時は Amazon Linux 2023 の最新 AMI を自動検索して利用します。
  特定バージョンを固定したい場合に指定してください。
  EOT
}

variable "iam_policy_arns" {
  type        = list(string)
  default     = []
  description = <<-EOT
  EC2 用 IAM ロールに追加でアタッチするポリシー ARN のリスト。
  既定で AmazonSSMManagedInstanceCore は自動付与されるため、
  S3 アクセスなど追加権限が必要な場合のみ指定してください。
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

