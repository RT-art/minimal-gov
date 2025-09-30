output "alb_arn" {
  value       = module.alb.arn
  description = "ALB ARN"
}

output "alb_dns_name" {
  value       = module.alb.dns_name
  description = "ALB DNS name"
}

output "alb_security_group_id" {
  value       = module.alb_sg.security_group_id
  description = "ALB用セキュリティグループID"
}

output "target_group_arn" {
  value       = try(module.alb.target_groups["app"].arn, null)
  description = "アプリ用ターゲットグループARN"
}

output "waf_web_acl_arn" {
  value       = module.waf_acl.aws_wafv2_arn
  description = "WAFv2 WebACL ARN"
}
