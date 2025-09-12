###############################################
# Security Group for VPC Endpoints
###############################################
resource "aws_security_group" "endpoints" {
  name        = "${var.vpc_name}-endpoints-sg"
  description = "Shared SG for all VPC interface endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS from VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

###############################################
# VPC Endpoints
###############################################
resource "aws_vpc_endpoint" "interface" {
  for_each = {
    for e in var.endpoints : e.name => e
    if e.type == "Interface"
  }

  vpc_id              = var.vpc_id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for sn in each.value.subnet_names : var.subnets[sn].id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = coalesce(lookup(each.value, "private_dns_enabled", null), true)

  tags = merge(
    { Name = each.key },
    var.tags,
  )
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = {
    for e in var.endpoints : e.name => e
    if e.type == "Gateway"
  }

  vpc_id            = var.vpc_id
  service_name      = each.value.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_id]

  tags = merge(
    { Name = each.key },
    var.tags,
  )
}
