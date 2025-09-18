output "share_arn" {
  description = "The ARN of the RAM resource share that was accepted"
  value       = aws_ram_resource_share_accepter.this.share_arn
}

output "status" {
  description = "Whether the RAM resource share was successfully accepted"
  value       = aws_ram_resource_share_accepter.this.status
}

output "id" {
  description = "The ID of the RAM resource share accepter"
  value       = aws_ram_resource_share_accepter.this.id
}
