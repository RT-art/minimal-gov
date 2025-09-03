#########################
# VPC とサブネット
#########################
resource "aws_vpc" "onprem" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "onprem-vpc"
  }
}

resource "aws_subnet" "onprem_private" {
  vpc_id            = aws_vpc.onprem.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "onprem-private-subnet"
  }
}

#########################
# セキュリティグループ（広めに許可）
#########################
resource "aws_security_group" "vpn" {
  name        = "onprem-vpn-sg"
  description = "allow all for testing"
  vpc_id      = aws_vpc.onprem.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "onprem-vpn-sg"
  }
}

#########################
# StrongSwan 用 EC2 インスタンス
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
  subnet_id                   = aws_subnet.onprem_private.id
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  associate_public_ip_address = false
  source_dest_check           = false

  # 実際の値をハードコードする。
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y strongswan

    cat <<'CONF' > /etc/strongswan/ipsec.conf
    config setup
      charondebug="ike 1, knl 1, cfg 0"
    conn aws-tgw
      left=%any
      leftid=@onprem
      leftsubnet=10.0.0.0/16
      right=<TGWのIPアドレス>
      rightid=@aws
      rightsubnet=<リモート側CIDR>
      ike=aes256-sha2_256-modp2048!
      esp=aes256-sha2_256!
      keyexchange=ikev2
      auto=start
    CONF

    cat <<'SECRETS' > /etc/strongswan/ipsec.secrets
    @onprem : PSK "変更してください"
    SECRETS

    systemctl enable strongswan
    systemctl restart strongswan
  EOF

  tags = {
    Name = "onprem-vpn"
  }
}

#########################
# ルートテーブル（双方向通信を想定）
#########################
resource "aws_route_table" "onprem" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name = "onprem-rt"
  }
}

resource "aws_route" "to_tgw" {
  route_table_id         = aws_route_table.onprem.id
  destination_cidr_block = "tgwアタッチメントがあるvpcのサイダー"
  instance_id            = aws_instance.vpn.id
}

resource "aws_route_table_association" "onprem_private" {
  subnet_id      = aws_subnet.onprem_private.id
  route_table_id = aws_route_table.onprem.id
}
