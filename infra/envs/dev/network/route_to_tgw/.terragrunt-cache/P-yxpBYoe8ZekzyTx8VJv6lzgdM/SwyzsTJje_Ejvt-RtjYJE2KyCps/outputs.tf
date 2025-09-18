output "route_ids" {
  description = "作成された TGW ルートの ID"
  value       = [for r in aws_route.to_tgw : r.id]
}
