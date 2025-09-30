#############################################
# Locals
#############################################
locals {
  name = "${var.app_name}-${var.env}-rds"

  # Derive DB parameter group family when using Postgres.
  # - If engine_version is provided (e.g., "16.3"), use its major ("16") -> "postgres16".
  # - If engine_version is null, use the first preferred version pattern (e.g., "16.*") -> "postgres16".
  pg_major = var.engine == "postgres" ? (
    var.engine_version != null
    ? split(".", var.engine_version)[0]
    : regex("\\d+", var.preferred_engine_versions[0])
  ) : null

  family = var.engine == "postgres" ? "postgres${local.pg_major}" : null
}

#############################################
# Secrets Manager
#############################################
resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "${local.name}-password"
  tags = merge(
    { Name = "${local.name}-password" },
    var.tags,
  )
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = random_password.db.result
}

#############################################
# Security Group 
#############################################
module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-sg"
  description = "Security group for ${local.name}"
  vpc_id      = var.vpc_id

  # Egress: allow all (outbound)
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound"
    }
  ]

  # Optional inbound from a specific SG on DB port
  ingress_with_source_security_group_id = var.allowed_sg_id != null ? [
    {
      from_port                = var.db_port
      to_port                  = var.db_port
      protocol                 = "tcp"
      source_security_group_id = var.allowed_sg_id
      description              = "Allow DB access from allowed SG"
    }
  ] : []

  tags = merge(
    { Name = "${local.name}-sg" },
    var.tags,
  )
}

#############################################
# RDS
#############################################
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier     = local.name
  engine         = var.engine
  engine_version = var.engine_version # null の場合は自動で最新を選択
  family         = local.family
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

  enabled_cloudwatch_logs_exports        = ["postgresql"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 30

  tags = merge(
    { Name = local.name },
    var.tags,
  )
}
