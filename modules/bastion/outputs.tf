###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
###############################################

output "instance_id" {
  description = "作成された Bastion EC2 の ID。例: SSM セッションのターゲットに module.bastion.instance_id を渡す。"
  value       = aws_instance.this.id
}

