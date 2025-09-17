output "rds_endpoint" {
  value       = module.rds.db_instance_endpoint
  description = "RDS endpoint"
}

output "rds_port" {
  value       = module.rds.db_instance_port
  description = "RDS port"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "RDS security group ID"
}

output "db_password_secret_arn" {
  value       = aws_secretsmanager_secret.db.arn
  description = "Secrets Manager ARN for the DB password"
}
