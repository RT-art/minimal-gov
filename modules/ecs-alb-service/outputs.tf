###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
###############################################

output "alb_dns_name" {
  description = <<-EOT
  作成された ALB の DNS 名。
  Route53 のエイリアスや疎通確認に利用します。
  例: module.ecs.alb_dns_name
  EOT
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = <<-EOT
  ALB の Hosted Zone ID。
  Route53 でエイリアスレコードを作成する際に必要です。
  例: module.ecs.alb_zone_id
  EOT
  value       = aws_lb.this.zone_id
}

output "service_security_group_id" {
  description = <<-EOT
  ECS タスク用セキュリティグループの ID。
  データベース等でこの SG からのアクセスを許可する際に利用します。
  例: module.ecs.service_security_group_id
  EOT
  value       = aws_security_group.task.id
}

