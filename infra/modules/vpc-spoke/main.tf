  locals {

  # 総サブネット数（AZ 数 × AZ あたりのプライベートサブネット個数）
  total_private_subnets = length(var.azs) * var.private_subnet_count_per_az
}

###############################################
# VPC
###############################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = var.tags
}

###############################################
# Subnet
###############################################
resource "aws_subnet" "private" {
  count                   = local.total_private_subnets
  vpc_id                  = aws_vpc.this.id

  # azs = [a, c], per_az = 3 のとき、
  # index:0..5 に対して 0..2 は a、3..5 は c となるように割当
  availability_zone       = element(var.azs, floor(count.index / var.private_subnet_count_per_az))

  # 各サブネットの CIDR を連番で作成
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_newbits, count.index)

  #public IP は自動付与しない
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format(
        "%s-private-%s-%02d",
        local.name_prefix,
        element(var.azs, floor(count.index / var.private_subnet_count_per_az)),
        count.index % var.private_subnet_count_per_az,
      )
    },
    var.tags,
  )
}

###############################################
# rtb
###############################################
resource "aws_route_table" "private" {
  count  = local.total_private_subnets
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = format(
        "%s-rt-private-%s-%02d",
        local.name_prefix,
        element(var.azs, floor(count.index / var.private_subnet_count_per_az)),
        count.index % var.private_subnet_count_per_az,
      )
    },
    var.tags,
  )
}

###############################################
# rtb association
###############################################
resource "aws_route_table_association" "private" {
  count          = local.total_private_subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

