###############################################
# Security Group for Route53 Resolver Endpoints
###############################################
resource "aws_security_group" "resolver" {
  name        = "${var.vpc_name}-resolver-sg"
  description = "Security Group for Route53 Resolver endpoints"
  vpc_id      = var.vpc_id

  # Inbound Resolver: オンプレからの DNS クエリを許可
  ingress {
    description = "Allow DNS from on-premises"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = var.onprem_cidrs
  }

  ingress {
    description = "Allow DNS from on-premises (TCP fallback)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.onprem_cidrs
  }

  # Outbound Resolver: AWS から外部へ
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

###############################################
# Inbound Resolver Endpoint
###############################################
resource "aws_route53_resolver_endpoint" "inbound" {
  count              = length(var.inbound_subnet_ids) > 0 ? 1 : 0
  name               = "${var.vpc_name}-inbound"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.resolver.id]

  ip_address {
    subnet_id = var.inbound_subnet_ids[0]
  }

  ip_address {
    subnet_id = var.inbound_subnet_ids[1]
  }

  tags = var.tags
}

###############################################
# Outbound Resolver Endpoint
###############################################
resource "aws_route53_resolver_endpoint" "outbound" {
  count              = length(var.outbound_subnet_ids) > 0 ? 1 : 0
  name               = "${var.vpc_name}-outbound"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.resolver.id]

  ip_address {
    subnet_id = var.outbound_subnet_ids[0]
  }

  ip_address {
    subnet_id = var.outbound_subnet_ids[1]
  }

  tags = var.tags
}

###############################################
# Outbound Resolver Rules
###############################################
resource "aws_route53_resolver_rule" "forward" {
  for_each = { for d in var.forward_rules : d.domain => d }

  domain_name          = each.value.domain
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound[0].id

  target_ip {
    ip   = each.value.target_ip
    port = 53
  }

  tags = var.tags
}

resource "aws_route53_resolver_rule_association" "forward_assoc" {
  for_each = aws_route53_resolver_rule.forward

  resolver_rule_id = each.value.id
  vpc_id           = var.vpc_id
}
