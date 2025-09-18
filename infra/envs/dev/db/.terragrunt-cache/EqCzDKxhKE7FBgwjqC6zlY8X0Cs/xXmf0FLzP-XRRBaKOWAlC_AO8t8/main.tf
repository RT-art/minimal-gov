locals {
  name = "${var.app_name}-${var.env}-rds"
}

# -----------------------------
# Secrets Manager
# -----------------------------
resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "${local.name}-password"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = random_password.db.result
}

# -----------------------------
# Security Group
# -----------------------------
module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name        = local.name
  description = "Security group for RDS ${local.name}"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = var.allowed_sg_id != null ? [
    {
      from_port                = var.db_port
      to_port                  = var.db_port
      protocol                 = "tcp"
      source_security_group_id = var.allowed_sg_id
    }
  ] : []

  egress_rules            = ["all-all"]
  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]

  tags = var.tags
}

# -----------------------------
# RDS 
# -----------------------------
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier     = local.name
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.username
  password = random_password.db.result  

  port                   = var.db_port
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true
  deletion_protection   = true

  multi_az                = true
  backup_retention_period = 7

  # CloudWatch Logs (PostgreSQL 用)
  enabled_cloudwatch_logs_exports   = ["postgresql"]
  create_cloudwatch_log_group       = true
  cloudwatch_log_group_retention_in_days = 30

  family = "postgres15"
  tags = var.tags
}
