output "inbound_resolver_id" {
  description = "Inbound resolver endpoint ID"
  value       = module.resolver.inbound_resolver_id
}

output "outbound_resolver_id" {
  description = "Outbound resolver endpoint ID"
  value       = module.resolver.outbound_resolver_id
}

output "resolver_rule_ids" {
  description = "Forward resolver rule IDs by domain"
  value       = module.resolver.resolver_rule_ids
}
