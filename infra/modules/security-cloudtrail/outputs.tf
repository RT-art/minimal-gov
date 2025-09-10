###############################################
# Outputs
# Only values required by callers are exposed. Comments describe
# typical use cases for each output.
###############################################

output "trail_arn" {
  description = "作成された CloudTrail トレイルの ARN。監視や委任設定で参照します。"
  value       = aws_cloudtrail.this.arn
}

output "bucket_name" {
  description = "CloudTrail ログを格納する S3 バケット名。ライフサイクル設定やアクセス許可の参照に使用します。"
  value       = aws_s3_bucket.this.bucket
}

