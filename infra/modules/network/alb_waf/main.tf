#############################################
# Locals
#############################################
locals {
  # app_name が長いと 32 文字制限に引っかかるので短縮
  short_app = substr(var.app_name, 0, 8) # 先頭8文字だけ
  name      = "${local.short_app}-${var.env}-alb"
}

#############################################
# Security Group 
#############################################
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.short_app}-${var.env}-albsg"
  description = "ALB SG"
  vpc_id      = var.vpc_id

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    for cidr in var.allow_cidrs : {
      from_port   = var.listener_port
      to_port     = var.listener_port
      protocol    = "tcp"
      description = "listener ${var.listener_port} from ${cidr}"
      cidr_blocks = cidr
    }
  ]

  tags = merge(
    {
      Name = "${local.short_app}-${var.env}-albsg"
    },
    var.tags
  )
}

#############################################
# ALB
#############################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name               = local.name
  load_balancer_type = "application"
  internal           = true

  vpc_id  = var.vpc_id
  subnets = var.alb_subnet_ids

  create_security_group = false
  security_groups       = [module.alb_sg.security_group_id]

  listeners = {
    http = {
      port     = var.listener_port
      protocol = "HTTP"
      forward = {
        target_group_key = "app"
      }
    }
  }

  target_groups = {
    app = {
      name              = "${local.short_app}-${var.env}-tg"
      protocol          = "HTTP"
      port              = var.listener_port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        path                = var.health_check_path
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  tags = merge(
    {
      Name = "${local.short_app}-${var.env}-alb"
    },
    var.tags
  )
}

#############################################
# WAF
#############################################
module "waf_ipset_allow" {
  source  = "aws-ss/wafv2/aws//modules/ip-set"
  version = "~> 3.12"

  name               = "${local.short_app}-${var.env}-allow"
  description        = "Allow CIDR set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allow_cidrs

  tags = merge(
    {
      Name = "${local.short_app}-${var.env}-allow"
    },
    var.tags
  )
}

module "waf_acl" {
  source  = "aws-ss/wafv2/aws"
  version = "~> 3.12"

  name        = "${local.short_app}-${var.env}-acl"
  description = "WAF ACL allowing only specified CIDRs"
  scope       = "REGIONAL"
  default_action = "block"

  rule = [
    {
      name     = "allow-cidr"
      priority = 1
      action   = { allow = {} }
      statement = {
        ip_set_reference_statement = {
          arn = module.waf_ipset_allow.aws_wafv2_ip_set_arn
        }
      }
      visibility_config = {
        metric_name                = "${local.name}-allow-cidr"
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
      }
    }
  ]

  resource_arn = [module.alb.arn]

  visibility_config = {
    metric_name                = local.name
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
  }

  tags = merge(
    {
      Name = "${local.short_app}-${var.env}-acl"
    },
    var.tags
  )
}
