output "trail_name" {
  description = "CloudTrail 名"
  value       = aws_cloudtrail.this.name
}


output "trail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.this.arn
}


output "s3_bucket_name" {
  description = "ログ保存先 S3 バケット名"
  value       = aws_s3_bucket.logs.id
}


output "kms_key_arn" {
  description = "利用中の KMS キー ARN（未使用なら null）"
  value       = local.kms_key_arn_effective
}