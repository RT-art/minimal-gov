###############################################
# Minimal Gov: On-prem Simulation module
#
# このモジュールはデモ用の「擬似オンプレ環境」を AWS 上に構築します。
# 以下のリソースをまとめて作成し、Site-to-Site VPN の動作確認などに
# 利用できる最小構成を提供します。
#
# 作成する主なリソース:
# - VPC（指定した CIDR で作成）
# - パブリックサブネット + ルートテーブル + IGW（インターネット接続）
# - strongSwan EC2 インスタンス（EIP 付与、Src/Dst チェック無効）
#
# 設計指針:
# - ロジックは可能な限り単純化し、読みやすさを最優先
# - セキュリティ既定値を有効化（暗号化、公開ブロック等）
# - 上位モジュールが依存する最小限の値のみを出力
###############################################

###############################################
# Data sources
# - AMI: 既定では Amazon Linux 2023 を使用。
#   strongSwan 専用 AMI を利用する場合は ami_id 変数で上書きします。
###############################################

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-kernel-6.1-x86_64*"]
  }
}

locals {
  # AMI ID は入力で指定された場合を優先し、未指定なら上記データソースを使用
  ami_id = var.ami_id != null && var.ami_id != "" ? var.ami_id : data.aws_ami.al2023.id
}

###############################################
# VPC and networking components
###############################################

# ベースとなる VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name = "${var.name_prefix}-vpc"
  }, var.tags)
}

# インターネットゲートウェイ（外部との通信を可能にする）
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${var.name_prefix}-igw"
  }, var.tags)
}

# パブリックサブネット（strongSwan を配置）
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = false # EIP を使用するため自動割当は無効化

  tags = merge({
    Name = "${var.name_prefix}-public"
  }, var.tags)
}

# ルートテーブル（IGW へ 0.0.0.0/0 をルーティング）
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${var.name_prefix}-public-rt"
  }, var.tags)
}

# インターネット向けデフォルトルート
resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# サブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

###############################################
# Security group for strongSwan instance
###############################################
resource "aws_security_group" "cgw" {
  name        = "${var.name_prefix}-cgw-sg"
  description = "Allow IPsec (UDP 500/4500) and ICMP for diagnostics"
  vpc_id      = aws_vpc.this.id

  # IKE (UDP 500)
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow IKEv2"
  }

  # NAT-T (UDP 4500)
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow NAT-T"
  }

  # ICMP for connectivity checks
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ICMP"
  }

  # Outbound: すべて許可（VPN トラフィックのため）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.name_prefix}-cgw-sg"
  }, var.tags)
}

###############################################
# EC2 instance representing on-premises gateway
###############################################
resource "aws_instance" "cgw" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.cgw.id]
  associate_public_ip_address = false
  source_dest_check           = false # VPN ルータとして動作させるため

  root_block_device {
    encrypted = true # デフォルトで EBS を暗号化
  }

  tags = merge({
    Name = "${var.name_prefix}-cgw"
  }, var.tags)
}

# Elastic IP を割り当て、外部から固定 IP でアクセス可能にする
resource "aws_eip" "cgw" {
  domain   = "vpc" # VPC 用 EIP を明示
  instance = aws_instance.cgw.id

  tags = merge({
    Name = "${var.name_prefix}-eip"
  }, var.tags)
}

###############################################
# Outputs are defined in outputs.tf
###############################################
