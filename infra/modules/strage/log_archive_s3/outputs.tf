output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.bucket.s3_bucket_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for default bucket encryption"
  value       = aws_kms_key.this.arn
}

output "kms_key_id" {
  description = "Key ID of the KMS key"
  value       = aws_kms_key.this.key_id
}
