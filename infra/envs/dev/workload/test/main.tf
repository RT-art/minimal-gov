terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "dev"
}

locals {
  region         = "ap-northeast-1"
  cidr_block     = "10.20.0.0/16"
  private_subnet = "10.20.1.0/24"
  az             = "ap-northeast-1c"
  name_prefix    = "workload-test"
  peer_vpc_cidr  = "10.10.0.0/16"
  tags = {
    Environment = "dev"
    Component   = "workload-test"
  }
  endpoint_service_map = {
    ssm         = "com.amazonaws.${local.region}.ssm"
    ssmmessages = "com.amazonaws.${local.region}.ssmmessages"
    ec2messages = "com.amazonaws.${local.region}.ec2messages"
  }
}

data "aws_ssm_parameter" "al2023_x86_64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "${path.module}/../../network/test/terraform.tfstate"
  }
}

locals {
  network_tgw_id = data.terraform_remote_state.network.outputs.transit_gateway_id
}

resource "aws_vpc" "this" {
  cidr_block           = local.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${local.name_prefix}-vpc" })
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_subnet
  availability_zone       = local.az
  map_public_ip_on_launch = false
  tags                    = merge(local.tags, { Name = "${local.name_prefix}-private-${local.az}" })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = "${local.name_prefix}-private-rt" })
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "instance" {
  name        = "${local.name_prefix}-instance"
  description = "Allow instance egress"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "ICMP from network VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.peer_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name_prefix}-instance-sg" })
}

resource "aws_security_group" "endpoint" {
  name        = "${local.name_prefix}-endpoint"
  description = "Allow HTTPS access to interface endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name_prefix}-endpoint-sg" })
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = local.endpoint_service_map
  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = true
  tags                = merge(local.tags, { Name = "${local.name_prefix}-${each.key}-endpoint" })
}

resource "aws_iam_role" "ssm" {
  name = "${local.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${local.name_prefix}-ssm-profile"
  role = aws_iam_role.ssm.name
}

resource "aws_instance" "private" {
  ami                         = data.aws_ssm_parameter.al2023_x86_64.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(local.tags, { Name = "${local.name_prefix}-ec2" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids                                      = [aws_subnet.private.id]
  transit_gateway_id                              = local.network_tgw_id
  vpc_id                                          = aws_vpc.this.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags                                            = merge(local.tags, { Name = "${local.name_prefix}-tgw-attachment" })
}

resource "aws_route" "to_network_vpc" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = local.peer_vpc_cidr
  transit_gateway_id     = local.network_tgw_id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.this]
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "instance_id" {
  value = aws_instance.private.id
}

output "endpoint_ids" {
  value = { for key, ep in aws_vpc_endpoint.interface : key => ep.id }
}

output "tgw_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.this.id
}
