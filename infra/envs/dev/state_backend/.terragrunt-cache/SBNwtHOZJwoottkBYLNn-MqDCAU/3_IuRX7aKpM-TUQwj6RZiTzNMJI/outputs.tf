output "state_bucket_name" {
  value = aws_s3_bucket.this.id
}

output "state_bucket_arn" {
  value = aws_s3_bucket.this.arn
}
