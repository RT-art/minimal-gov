locals {
  name = var.name
}

# WAF: allow-list via IP set
resource "aws_wafv2_ip_set" "allow" {
  name               = "${local.name}-allow"
  description        = "Allow CIDR set for ${local.name}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allow_cidrs

  tags = merge(var.tags, { Name = "${local.name}-allow-ipset" })
}

resource "aws_wafv2_web_acl" "this" {
  name        = "${local.name}-acl"
  description = "WAF ACL allowing only specified CIDRs"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "allow-cidr"
    priority = 1
    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allow.arn
      }
    }

    visibility_config {
      metric_name                = "${local.name}-allow-cidr"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    metric_name                = local.name
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
  }

  tags = merge(var.tags, { Name = "${local.name}-acl" })
}

# ALB security group (allow listener port from allow_cidrs)
resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "ALB SG for ${local.name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${local.name}-alb-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_cidrs" {
  for_each          = toset(var.allow_cidrs)
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = each.value
  from_port         = var.listener_port
  to_port           = var.listener_port
  ip_protocol       = "tcp"
}

# ALB + TG + Listener
resource "aws_lb" "this" {
  name               = "${local.name}-alb"
  load_balancer_type = "application"
  # Internal-facing ALB (no IGW in this project)
  internal           = true
  subnets            = var.alb_subnet_ids
  security_groups    = [aws_security_group.alb.id]

  tags = merge(var.tags, { Name = "${local.name}-alb" })
}

resource "aws_lb_target_group" "app" {
  name     = "${local.name}-tg"
  port     = var.listener_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "${local.name}-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_wafv2_web_acl_association" "assoc" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
