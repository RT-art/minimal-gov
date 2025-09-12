output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.api.alb_dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
  value       = module.api.alb_zone_id
}

output "service_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = module.api.service_security_group_id
}
