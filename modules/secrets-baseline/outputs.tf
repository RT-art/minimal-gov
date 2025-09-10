###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
###############################################

output "secret_arns" {
  description = <<-EOT
  作成された Secrets Manager シークレットの ARN マップ。
  例: module.secrets_baseline.secret_arns["db_password"]
  EOT
  value = {
    for k, v in aws_secretsmanager_secret.this : k => v.arn
  }
}

