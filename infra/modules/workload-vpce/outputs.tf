###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
###############################################

output "endpoint_ids" {
  description = <<-EOT
  作成した VPC エンドポイントの ID マップ。
  キーはサービス短縮名（例: "ecr.api", "logs", "s3"）です。
  例: module.workload_vpce.endpoint_ids["ecr.api"]
  EOT
  value = merge(
    { for k, v in aws_vpc_endpoint.interface : k => v.id },
    { s3 = aws_vpc_endpoint.s3.id }
  )
}
