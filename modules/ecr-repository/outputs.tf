###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
# 利用方法のヒントをコメントとして併記します。
###############################################

output "repository_url" {
  description = <<-EOT
  作成された ECR リポジトリのプッシュ/プル用 URL。
  例: Docker イメージを push する際に "<repository_url>:latest" のように参照します。
  EOT
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = <<-EOT
  ECR リポジトリの ARN。
  例: IAM ポリシーでリソース指定する際に利用します。
  EOT
  value       = aws_ecr_repository.this.arn
}

