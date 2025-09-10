###############################################
# Outputs
###############################################

output "permission_set_arn" {
  description = "作成された Permission Set の ARN。追加の割当や監査で参照します。"
  value       = aws_ssoadmin_permission_set.this.arn
}

