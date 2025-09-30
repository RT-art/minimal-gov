# TGWアタッチメントの承認をterraformで実現するためのモジュールです。
# 依存関係をシンプルにするため単一モジュールとしています。

###############################################
# Transit Gateway VPC Attachment Accepter
###############################################
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {
  transit_gateway_attachment_id = var.transit_gateway_attachment_id

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-${var.env}-tgw-att-accepter"
    }
  )
}

