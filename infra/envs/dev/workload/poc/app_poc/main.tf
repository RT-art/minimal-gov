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
  name_prefix = "workload-test-app"
  vpc_cidr    = "10.20.0.0/16"
  tags = {
    Environment = "dev"
    Component   = "workload-test-app"
  }

  subnets = {
    alb = {
      cidr   = "10.20.10.0/24"
      az     = "ap-northeast-1c"
      public = true
    }
    ecs = {
      cidr   = "10.20.11.0/24"
      az     = "ap-northeast-1c"
      public = true
    }
    db = {
      cidr   = "10.20.21.0/24"
      az     = "ap-northeast-1c"
      public = false
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-${each.key}-${each.value.az}"
    Tier = each.value.public ? "public" : "private"
  })
}

resource "aws_route_table_association" "public" {
  for_each       = { for name, subnet in aws_subnet.this : name => subnet if local.subnets[name].public }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = { for name, subnet in aws_subnet.this : name => subnet if !local.subnets[name].public }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

output "vpc_id" {
  description = "VPC ID for workload app environment"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "IDs for created subnets grouped by purpose"
  value = {
    for k, subnet in aws_subnet.this : k => subnet.id
  }
}

output "public_route_table_id" {
  description = "Route table ID for public subnets"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Route table ID for private subnets"
  value       = aws_route_table.private.id
}
