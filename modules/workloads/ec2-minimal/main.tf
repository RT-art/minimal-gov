########################################
# Minimal EC2 (default VPC)
########################################

# data "aws_vpc" "default" {
#   default = true
# }

resource "aws_default_vpc" "this" {}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.this.id]
  }
}


# Amazon Linux 2023 (x86_64) を自動選択
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  subnet_id = data.aws_subnets.default.ids[0]
  common_tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-${var.env}-ec2"
    }
  )
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true

  tags = local.common_tags
}