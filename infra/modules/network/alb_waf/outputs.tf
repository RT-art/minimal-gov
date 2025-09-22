output "load_balancer_arn" {
  value       = aws_lb.this.arn
  description = "ARN of the created ALB"
}

output "load_balancer_dns_name" {
  value       = aws_lb.this.dns_name
  description = "DNS name of the created ALB"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "ARN of the target group"
}

output "security_group_id" {
  value       = aws_security_group.alb.id
  description = "Security group ID attached to ALB"
}

output "web_acl_arn" {
  value       = aws_wafv2_web_acl.this.arn
  description = "WAF Web ACL ARN"
}

output "ip_set_arn" {
  value       = aws_wafv2_ip_set.allow.arn
  description = "WAF allow list IP set ARN"
}

