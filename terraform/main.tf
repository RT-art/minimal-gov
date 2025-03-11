
resource "aws_vpc" "vpc-practice-terraform" {
  cidr_block                       = "10.0.0.0/16"
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
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
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

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # ワイルドカードを使用
  }
}
resource "aws_instance" "rt-practice-terraform" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet-practice-terraform.id
  vpc_security_group_ids      = [aws_security_group.security-group-practice-terraform.id]
  associate_public_ip_address = true
  key_name                    = "ec2-practice-docker.pem"
  user_data                   = <<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    docker stop my-app || true
    docker rm my-app || true
    docker run -d --name my-app -p 80:5000 rtart/my-app:latest
    echo "Successfully deployed by Terraform!" > /tmp/terraform_deployed.txt
    EOF

  tags = {
    Name = "rt-practice-terraform"
  }
}