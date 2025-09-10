###############################################
# Outputs
# - 上位モジュールが依存に必要な最小限の値のみを出力します。
###############################################

output "finding_aggregator_arn" {
  value       = aws_securityhub_finding_aggregator.this.id
  description = <<-EOT
  作成された Security Hub Finding Aggregator の ARN。
  他リージョンの集約設定や可視化ツールとの連携に利用できます。
  EOT
}

