output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_port" {
  description = "The database port"
  value       = module.rds.db_instance_port
}

output "rds_password_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the DB password"
  value       = aws_secretsmanager_secret.db.arn
}
