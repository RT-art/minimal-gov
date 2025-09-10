###############################################
# Outputs
# 利用者が依存に必要な最小限の情報のみを公開します。
###############################################

output "server_id" {
  value       = aws_transfer_server.this.id
  description = "作成された Transfer Family サーバの ID。ユーザ追加などで参照します。"
}

output "server_endpoint" {
  value       = aws_transfer_server.this.endpoint
  description = "SFTP クライアントが接続するエンドポイント URL。"
}

output "bucket_name" {
  value       = aws_s3_bucket.this.id
  description = "SFTP データを格納する S3 バケット名。外部連携などで利用します。"
}
