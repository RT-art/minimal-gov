###############################################
# Variables
# すべての入力変数には詳細な説明を付与しています。
###############################################

variable "role_name" {
  type        = string
  description = <<-EOT
  作成する IAM ロール名。
  CI/CD パイプラインから AWS リソースへのデプロイ時に使用します。
  一意で分かりやすい名前を推奨します。
  EOT
}

variable "github_org" {
  type        = string
  default     = null
  description = <<-EOT
  GitHub Actions からのデプロイを許可する場合の GitHub 組織名。
  `github_repo` とセットで指定すると、該当リポジトリのワークフローのみ
  このロールを引き受けられるように OIDC トラストポリシーを設定します。
  未指定の場合、GitHub 向けの設定は作成されません。
  EOT
}

variable "github_repo" {
  type        = string
  default     = null
  description = <<-EOT
  GitHub Actions からのデプロイを許可する対象リポジトリ名。
  `github_org` と併せて指定した場合にのみ有効となります。
  EOT
}

variable "trusted_principal_arns" {
  type        = list(string)
  default     = []
  description = <<-EOT
  CodePipeline など AWS 内の別アカウントやサービスからこのロールを
  Assume させる場合のプリンシパル ARN のリスト。
  GitHub Actions を利用しないケースで使用します。
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  追加で付与したいタグのマップ。
  プロバイダの default_tags と組み合わせて運用情報を付与します。
  EOT
}

###############################################
# End of variables
###############################################
