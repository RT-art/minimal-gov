###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
###############################################

output "db_instance_endpoint" {
  description = "RDS インスタンスへの接続エンドポイント。例: アプリケーションの DB ホストとして module.rds.db_instance_endpoint を指定。"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_identifier" {
  description = "作成された RDS インスタンスの識別子。運用監視や追加設定の参照に使用します。"
  value       = aws_db_instance.this.id
}

