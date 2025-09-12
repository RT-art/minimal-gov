output "recorder_name" {
  value       = module.config.recorder_name
  description = "Name of the AWS Config recorder"
}

output "delivery_channel_name" {
  value       = module.config.delivery_channel_name
  description = "Name of the AWS Config delivery channel"
}

output "aggregator_arn" {
  value       = module.config.aggregator_arn
  description = "ARN of the organization Config aggregator"
}
