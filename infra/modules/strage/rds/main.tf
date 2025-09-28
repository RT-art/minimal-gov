locals {
  name = "${var.app_name}-${var.env}-rds"
}

# Ensure security group VPC matches subnets' VPC
data "aws_subnet" "primary" {
  id = var.subnet_ids[0]
}

locals {
  subnets_vpc_id = data.aws_subnet.primary.vpc_id
}

# Resolve engine version
data "aws_rds_engine_version" "selected_exact" {
  count   = var.engine_version != null ? 1 : 0
  engine  = var.engine
  version = var.engine_version
}

data "aws_rds_engine_version" "selected_latest" {
  count  = var.engine_version == null ? 1 : 0
  engine = var.engine
  # Pick the region's default version for the engine
  default_only = true
}

locals {
  selected_engine            = var.engine_version != null ? data.aws_rds_engine_version.selected_exact[0] : data.aws_rds_engine_version.selected_latest[0]
  effective_engine_version   = var.engine_version != null ? var.engine_version : local.selected_engine.version
  effective_parameter_family = local.selected_engine.parameter_group_family
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
resource "aws_security_group" "rds" {
  name        = "${local.name}-sg"
  description = "Security group for RDS ${local.name}"
  vpc_id      = local.subnets_vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "from_allowed_sg" {
  count                        = var.allowed_sg_id != null ? 1 : 0
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = var.allowed_sg_id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

# -----------------------------
# RDS 
# -----------------------------
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier     = local.name
  engine         = var.engine
  engine_version = local.effective_engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.username
  password = random_password.db.result

  port                   = var.db_port
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true
  deletion_protection   = true

  multi_az                = true
  backup_retention_period = 7

  # CloudWatch Logs (PostgreSQL 用)
  enabled_cloudwatch_logs_exports        = ["postgresql"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 30

  family = local.effective_parameter_family
  tags   = var.tags
}
