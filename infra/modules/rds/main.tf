###############################################
# Minimal Gov: RDS module
#
# このモジュールは Amazon RDS の単一 DB インスタンスを作成します。
# - 指定されたサブネット群に DB サブネットグループを構成
# - ストレージ暗号化やパブリックアクセス無効化を既定で有効化
# - 最小限の入力で安全な RDS を構築可能
###############################################

###############################################
# Locals
###############################################
locals {
  # name_prefix は未指定なら "rds" を利用
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "rds"
}

###############################################
# DB Subnet Group
# - RDS が配置されるサブネットをまとめる
###############################################
resource "aws_db_subnet_group" "this" {
  name        = "${local.name_prefix}-subnet-group"
  description = "Subnets for RDS ${local.name_prefix}"
  subnet_ids  = var.subnet_ids

  tags = merge({
    Name = "${local.name_prefix}-subnet-group"
  }, var.tags)
}

###############################################
# RDS DB Instance
# - 単一インスタンスの DB を作成
# - ストレージ暗号化、公衆アクセス無効化、削除保護などを既定で有効化
###############################################
resource "aws_db_instance" "this" {
  identifier             = "${local.name_prefix}-db"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  db_name                = var.db_name
  username               = var.username
  password               = var.password

  multi_az                = var.multi_az
  publicly_accessible     = false # パブリックネットワークからのアクセスを禁止
  storage_encrypted       = true  # AWS 既定 KMS キーで暗号化
  backup_retention_period = var.backup_retention_days
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  apply_immediately       = var.apply_immediately

  tags = merge({
    Name = "${local.name_prefix}-db"
  }, var.tags)
}

