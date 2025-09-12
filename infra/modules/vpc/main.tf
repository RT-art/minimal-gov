###############################################
# VPC
###############################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    { Name = var.vpc_name },
    var.tags
  )
}

###############################################
# VPC Flow Logs (集約先: セキュリティアカウント)
###############################################
resource "aws_iam_role" "flowlogs" {
  name = "flowlogs-to-cw"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "vpc-flow-logs.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

  tags = {
    LogType = "VPCFlow"
  }

resource "aws_iam_role_policy_attachment" "flowlogs_attach" {
  role       = aws_iam_role.flowlogs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_flow_log" "this" {
  vpc_id          = aws_vpc.this.id
  log_destination = "arn:aws:logs:ap-northeast-1:${var.security_account_id}:log-group:/central/vpc-flow-logs"
  traffic_type    = "ALL"
  log_format      = var.log_format
  iam_role_arn    = aws_iam_role.flowlogs.arn
}

###############################################
# Subnet
###############################################
resource "aws_subnet" "private" {
  for_each = { for s in var.subnets : s.name => s }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = var.vpc_name
  }
}
###############################################
# rtb
###############################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { Name = "${var.vpc_name}-rt-private" },
    var.tags,
  )
}

###############################################
# rtb association
###############################################
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

###############################################
# routes to Transit Gateway
###############################################
resource "aws_route" "to_tgw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}