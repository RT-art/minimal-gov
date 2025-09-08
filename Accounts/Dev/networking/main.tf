resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_a" {
  count                   = 3
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_c" {
  count                   = 3
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 3)
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
}

# --- TGW 共有を受け入れる --------------------------------------
data "aws_ram_resource_share" "tgw_share" {
  name = "tgw-hub-share" # Network 側で作成した Share 名
}

resource "aws_ram_resource_share_accepter" "tgw_share" {
  share_arn = data.aws_ram_resource_share.tgw_share.arn
}

# 共有された TGW を参照 (Name タグで検索)
data "aws_ec2_transit_gateway" "hub" {
  filter {
    name   = "tag:Name"
    values = ["tgw-hub"]
  }
}

# Dev VPC を TGW にアタッチ
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_vpc" {
  transit_gateway_id = data.aws_ec2_transit_gateway.hub.id
  vpc_id             = aws_vpc.this.id
  subnet_ids = concat(
    aws_subnet.private_a[*].id,
    aws_subnet.private_c[*].id
  )
  tags = { Name = "tgw-dev-attach" }
}
