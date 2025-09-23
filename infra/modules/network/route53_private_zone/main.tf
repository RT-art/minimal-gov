locals {
  name = replace(var.zone_name, ".", "-")
}

resource "aws_route53_zone" "this" {
  name          = var.zone_name
  comment       = coalesce(var.comment, "Private hosted zone for ${var.app_name} ${var.env}")
  force_destroy = false

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(var.tags, {
    Name        = "${local.name}-phz"
    Application = var.app_name
    Environment = var.env
  })
}
