#############################################
# Locals
#############################################
locals {
  name = "${var.app_name}-${var.env}-alb"
}

#############################################
# Security Group 
#############################################
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.app_name}-${var.env}-albsg"
  description = "ALB SG"
  vpc_id      = var.vpc_id

  # 送信はすべて許可（0.0.0.0/0）
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]

  # リスナーポートを allow_cidrs からのみ許可
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
      Name = "${var.app_name}-${var.env}-albsg"
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

  name               = "${var.app_name}-${var.env}-alb"
  load_balancer_type = "application"
  internal           = true

  vpc_id  = var.vpc_id
  subnets = var.alb_subnet_ids

  # SGは上で作ったものを使用（モジュール側の自動生成は使わない）
  create_security_group = false
  security_groups       = [module.alb_sg.security_group_id]

  # リスナー（HTTP）
  listeners = {
    http = {
      port     = var.listener_port
      protocol = "HTTP"
      forward = {
        target_group_key = "app"
      }
    }
  }

  # ターゲットグループ（登録は別途）
  target_groups = {
    app = {
      name        = "${var.app_name}-${var.env}-albtg"
      protocol    = "HTTP"
      port        = var.listener_port
      target_type = "ip"
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
    Name = "${var.app_name}-${var.env}-ecssg"
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

  name               = "${var.app_name}-${var.env}-alb-allow"
  description        = "Allow CIDR set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allow_cidrs

  tags = merge(
  {
    Name = "${var.app_name}-${var.env}-ecssg"
  },
  var.tags
    )
}

# WebACL 本体 + ALB関連付け
module "waf_acl" {
  source  = "aws-ss/wafv2/aws"
  version = "~> 3.12"

  name        = "${var.app_name}-${var.env}-acl"
  description = "WAF ACL allowing only specified CIDRs"
  scope       = "REGIONAL"

  # マッチしない場合はブロック
  default_action = "block"

  # ルール: IPSetに一致したら許可
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

  # ALBと関連付け（リストで渡す仕様）
  resource_arn = [module.alb.arn]

  visibility_config = {
    metric_name                = local.name
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
  }

  # CloudWatch Logs/KDF等のロギングを使う場合は以下を有効化
  # enabled_logging_configuration = true
  # log_destination_configs       = "arn:aws:logs:ap-northeast-1:123456789012:log-group:/aws/wafv2/${local.name}"

  tags = merge(
  {
    Name = "${var.app_name}-${var.env}-ecssg"
  },
  var.tags
    )
}
