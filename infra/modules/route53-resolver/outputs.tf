output "inbound_resolver_id" {
  value       = aws_route53_resolver_endpoint.inbound[0].id
  description = "Inbound resolver endpoint ID"
}

output "outbound_resolver_id" {
  value       = aws_route53_resolver_endpoint.outbound[0].id
  description = "Outbound resolver endpoint ID"
}

output "resolver_rule_ids" {
  value       = { for k, v in aws_route53_resolver_rule.forward : k => v.id }
  description = "Forward resolver rule IDs by domain"
}
