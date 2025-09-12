data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "minimal-gov-dev-backend-tfstate-ap-northeast-1-351277498040"
    key    = "state/vpc/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Database security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow DB access from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

module "db" {
  source                 = "../../../../modules/rds"
  name_prefix            = "dev"
  subnet_ids             = [for az, ids in data.terraform_remote_state.vpc.outputs.private_subnet_ids_by_az : ids[0]]
  vpc_security_group_ids = [aws_security_group.db.id]
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  multi_az               = var.multi_az
  backup_retention_days  = var.backup_retention_days
  skip_final_snapshot    = var.skip_final_snapshot
  apply_immediately      = var.apply_immediately
  tags                   = var.tags
}
