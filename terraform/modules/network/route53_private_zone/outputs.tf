output "zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = aws_route53_zone.this.zone_id
}

output "arn" {
  description = "ARN of the Route53 hosted zone"
  value       = aws_route53_zone.this.arn
}

