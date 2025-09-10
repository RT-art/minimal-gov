###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
# 利用方法のヒントをコメントとして併記します。
###############################################

output "security_group_id" {
  description = "エンドポイント ENI に適用したセキュリティグループ ID。例: 他のエンドポイントで再利用する場合に参照。"
  value       = aws_security_group.endpoints.id
}

output "interface_endpoint_ids" {
  description = <<-EOT
  作成したインターフェース型 VPC エンドポイントの ID マップ。
  例: module.vpc_endpoints_baseline.interface_endpoint_ids["ssm"] のように参照可能。
  EOT
  value = {
    for k, v in aws_vpc_endpoint.interface : k => v.id
  }
}

output "gateway_endpoint_ids" {
  description = <<-EOT
  作成したゲートウェイ型 VPC エンドポイントの ID マップ。
  例: module.vpc_endpoints_baseline.gateway_endpoint_ids["s3"].
  EOT
  value = {
    for k, v in aws_vpc_endpoint.gateway : k => v.id
  }
}

