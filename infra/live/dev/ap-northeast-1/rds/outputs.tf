output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.db.db_instance_endpoint
}

output "db_instance_identifier" {
  description = "Identifier of the RDS instance"
  value       = module.db.db_instance_identifier
}

output "security_group_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.db.id
}
