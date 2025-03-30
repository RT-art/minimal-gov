resource "aws_vpc" "vpc-practice-terraform" {
  cidr_block                       = var.vpc_cidr_block
  assign_generated_ipv6_cidr_block = false
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  tags = {
    Name = "vpc-practice-terraform"
  }
}

resource "aws_subnet" "subnet-practice-terraform" {
  vpc_id                  = aws_vpc.vpc-practice-terraform.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-practice-terraform"
  }
}

resource "aws_internet_gateway" "internet-gateway-practice-terraform" {
  vpc_id = aws_vpc.vpc-practice-terraform.id
  tags = {
    Name = "internet-gateway-practice-terraform"
  }
}

resource "aws_default_route_table" "default-route-table-practice-terraform" {
  default_route_table_id = aws_vpc.vpc-practice-terraform.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway-practice-terraform.id
  }
}


resource "aws_security_group" "security-group-practice-terraform" {
  vpc_id = aws_vpc.vpc-practice-terraform.id
  tags = {
    Name = "security-group-practice-terraform"
  }
}

resource "aws_security_group_rule" "http-ingress-rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-practice-terraform.id
}

resource "aws_security_group_rule" "ssh-ingress-rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-practice-terraform.id
}

resource "aws_security_group_rule" "https-ingress-rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-practice-terraform.id
}
#セキュリティグループのアウトバウンドを未設定にしてたらlinuxコマンド反応しなかったため、全てのアウトバウンドを許可するように変更
resource "aws_security_group_rule" "all-egress-rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-practice-terraform.id
}

#参考にした記事のamiが、amaoznon-linux-2だったので、最新のamiを取得するように変更
data "aws_ami" "amazon_linux_latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}
# EIPを作成し、パブリックIPが変わってもCICDが動作するようにする
# resource "aws_eip" "eip_for_instance" {
#   tags = {
#     Name = "eip-rt-practice"
#   }
# } # ← このブロックは不要

# EIPを手動で作成し、destroy時に削除しないようにする
data "aws_eip" "rt_eip" {
  filter {
    name   = "tag:Name"
    values = ["rt-practice-eip"]
  }
}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.rt-practice-terraform.id
  allocation_id = data.aws_eip.rt_eip.id
}

resource "aws_instance" "rt-practice-terraform" {
  ami                         = data.aws_ami.amazon_linux_latest.id #amiの名前変更
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet-practice-terraform.id
  vpc_security_group_ids      = [aws_security_group.security-group-practice-terraform.id]
  associate_public_ip_address = false # EIPを使うため、パブリックIPは割り当てない
  key_name                    = var.instance_key_name
  user_data = templatefile("setup-docker.sh.tpl", {
    docker_image_name = var.docker_image_name
  })

  tags = {
    Name = "rt-practice-terraform"
  }
}