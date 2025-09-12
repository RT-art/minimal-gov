###############################################
# Security Group
###############################################
output "endpoint_sg_id" {
  description = "VPCエンドポイント用セキュリティグループID"
  value       = aws_security_group.endpoints.id
}

###############################################
# VPC Endpoint IDs
###############################################
output "interface_endpoint_ids" {
  description = "Interface VPCエンドポイントのID (name→id)"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "gateway_endpoint_ids" {
  description = "Gateway VPCエンドポイントのID (name→id)"
  value       = { for k, v in aws_vpc_endpoint.gateway : k => v.id }
}

output "all_endpoint_ids" {
  description = "全VPCエンドポイントのID (name→id)"
  value = merge(
    { for k, v in aws_vpc_endpoint.interface : k => v.id },
    { for k, v in aws_vpc_endpoint.gateway : k => v.id }
  )
}

###############################################
# DNSエントリ（Interfaceのみ）
###############################################
output "interface_endpoint_dns_entries" {
  description = "Interface VPCエンドポイントのDNSエントリ"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.dns_entry }
}
