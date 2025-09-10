###############################################
# Outputs
# 上位 module が依存関係として利用する最小限の値のみを公開します。
###############################################

output "permission_set_arn" {
  description = "作成された Permission Set の ARN。追加の割当や監査で参照します。"
  value       = aws_ssoadmin_permission_set.this.arn
}

