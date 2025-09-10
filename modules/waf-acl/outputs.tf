###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
# 利用方法のヒントをコメントとして併記します。
###############################################

output "web_acl_arn" {
  description = <<-EOT
  作成された WAF Web ACL の ARN。
  例: ALB や API Gateway v2 で WAF を有効化する際に
  `waf_acl_arn = module.waf_acl.web_acl_arn` のように渡します。
  EOT
  value       = aws_wafv2_web_acl.this.arn
}

output "ip_set_arn" {
  description = <<-EOT
  許可 CIDR を登録した IP Set の ARN。
  CLI や別モジュールからアドレスを追加/削除したい場合に参照します。
  EOT
  value       = aws_wafv2_ip_set.allow.arn
}

