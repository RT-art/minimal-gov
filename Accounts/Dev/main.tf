terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# VPC の作成
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

# ap-northeast-1a のプライベートサブネット（3つ）
resource "aws_subnet" "private_a" {
  count                   = 3
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

# ap-northeast-1c のプライベートサブネット（3つ）
resource "aws_subnet" "private_c" {
  count                   = 3
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 3)
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
}