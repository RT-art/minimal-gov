data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "minimal-gov-dev-backend-tfstate-ap-northeast-1-351277498040"
    key    = "state/vpc/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_security_group" "vpce" {
  name        = "vpce-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
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

module "vpce" {
  source            = "../../../../modules/workload-vpce"
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids        = flatten(values(data.terraform_remote_state.vpc.outputs.private_subnet_ids_by_az))
  security_group_id = aws_security_group.vpce.id
  services          = var.services
  tags              = var.tags
}
