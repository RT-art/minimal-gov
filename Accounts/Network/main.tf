# minimal-gov/Accounts/Network/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# --- VPC & サブネット ---------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "network-vpc" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "private-1a" }
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "ap-northeast-1c"
  tags              = { Name = "private-1c" }
}

# --- Transit Gateway ハブ ------------------------------------------------

resource "aws_ec2_transit_gateway" "hub" {
  description                    = "central transit gateway"
  amazon_side_asn                = 64512
  dns_support                    = "enable"
  vpn_ecmp_support               = "enable"
  multicast_support              = "disable"
  auto_accept_shared_attachments = "enable"

  tags = { Name = "tgw-hub" }
}

# VPC を TGW にアタッチ (必要に応じて削除可)
resource "aws_ec2_transit_gateway_vpc_attachment" "hub_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  vpc_id             = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
  tags = { Name = "tgw-attachment" }
}

# --- RAM による TGW 共有 -------------------------------------------------

# 組織情報を取得 (既存の AWS Organizations 前提)
data "aws_organizations_organization" "current" {}

resource "aws_ram_resource_share" "tgw_share" {
  name                      = "tgw-hub-share"
  allow_external_principals = false
}

# 共有対象: 組織全体
resource "aws_ram_principal_association" "tgw_org" {
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
  principal          = data.aws_organizations_organization.current.arn
}

# TGW を RAM リソース共有に紐付け
resource "aws_ram_resource_association" "tgw_assoc" {
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
  resource_arn       = aws_ec2_transit_gateway.hub.arn
}
