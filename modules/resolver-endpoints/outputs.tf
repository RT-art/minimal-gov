###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
# 利用方法のヒントをコメントとして併記します。
###############################################

output "security_group_id" {
  description = "Resolver Endpoints に適用したセキュリティグループ ID。既存 SG 指定時はその ID。"
  value       = coalesce(var.security_group_id, try(aws_security_group.resolver[0].id, null))
}

output "inbound_endpoint_id" {
  description = <<-EOT
  Inbound Resolver Endpoint の ID（未作成時は null）。
  例: `module.resolver_endpoints.inbound_endpoint_id` を、Resolver ルールのターゲットなどで参照。
  EOT
  value = try(aws_route53_resolver_endpoint.inbound[0].id, null)
}

output "outbound_endpoint_id" {
  description = <<-EOT
  Outbound Resolver Endpoint の ID（未作成時は null）。
  例: `module.resolver_endpoints.outbound_endpoint_id` を、アウトバウンド用の Resolver ルールで参照。
  EOT
  value = try(aws_route53_resolver_endpoint.outbound[0].id, null)
}

