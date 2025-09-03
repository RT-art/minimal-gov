#########################
# VPC とパブリックサブネット
#########################
resource "aws_vpc" "onprem" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "onprem-vpc"
  }
}

resource "aws_subnet" "onprem_public" {
  vpc_id                  = aws_vpc.onprem.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "onprem-public-subnet"
  }
}

#########################
# インターネットゲートウェイとルート
#########################
resource "aws_internet_gateway" "onprem_igw" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name = "onprem-igw"
  }
}

resource "aws_route_table" "onprem_public" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name = "onprem-public-rt"
  }
}

# すべての通信をインターネットへ
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.onprem_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.onprem_igw.id
}

resource "aws_route_table_association" "onprem_public_assoc" {
  subnet_id      = aws_subnet.onprem_public.id
  route_table_id = aws_route_table.onprem_public.id
}

#########################
# EIP 付き EC2（StrongSwan 用）
#########################
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "vpn" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.onprem_public.id
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  associate_public_ip_address = true # Public IP を自動で付与
  source_dest_check           = false

  # 実際の値をハードコードする。
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y strongswan
    # （StrongSwan の設定は省略）
  EOF

  tags = {
    Name = "onprem-vpn"
  }
}

# Elastic IP を明示的に割り当てる場合（省略可）
resource "aws_eip" "vpn_eip" {
  vpc      = true
  instance = aws_instance.vpn.id

  tags = {
    Name = "onprem-vpn-eip"
  }
}
