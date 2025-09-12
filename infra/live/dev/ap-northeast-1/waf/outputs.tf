output "web_acl_arn" {
  description = "ARN of the created WAF Web ACL"
  value       = module.waf.web_acl_arn
}

output "ip_set_arn" {
  description = "ARN of the allow IP set"
  value       = module.waf.ip_set_arn
}
