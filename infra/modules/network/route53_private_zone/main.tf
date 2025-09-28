###############################################
# Route53 PrivateHostZone
###############################################
# phz本体
resource "aws_route53_zone" "this" {
  name          = "${var.app_name}-${var.env}-phz"
  comment       = "Private hosted zone for ${var.app_name}-${var.env}"
  force_destroy = var.force_destroy

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(
    {
      Name = "${var.app_name}-${var.env}-vpce-sg"
    },
    var.tags
  )
}

# レコードセット
resource "aws_route53_record" "this" {
  for_each = { for r in var.records : r.name => r }

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type

  ttl     = try(each.value.ttl, null)
  records = try(each.value.records, null)

  # エイリアスレコード作成用。ailasの値があるときのみ繰り返す
  dynamic "alias" {
    for_each = try(each.value.alias, null) != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = try(alias.value.evaluate_target_health, true)
    }
  }
}