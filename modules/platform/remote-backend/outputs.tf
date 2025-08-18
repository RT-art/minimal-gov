output "state_bucket_name" {
  value = module.state_bucket.s3_bucket_id
}

output "state_bucket_arn" {
  value = module.state_bucket.s3_bucket_arn
}