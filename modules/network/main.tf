  resource "aws_vpc" "vpc-practice-terraform" {
    cidr_block                       = var.module_vpc_cidr_block
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
    cidr_block              = var.module_subnet_cidr_block
    availability_zone       = var.module_availability_zone
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