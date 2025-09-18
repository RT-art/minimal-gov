###############################################
# Transit Gateway 
###############################################
resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments ? "enable" : "disable" # false -> "disable"に変換して、UX向上
  default_route_table_association = var.default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = var.default_route_table_propagation ? "enable" : "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags = merge(
    var.tags,
    { 
      Name = "${var.app_name}-${var.env}-tgw" 
    }
  )
}

###############################################
# AWS RAM
###############################################
resource "aws_ram_resource_share" "this" {
  name                      = "${var.app_name}-${var.env}-tgw-ram"
  allow_external_principals = false
  tags = merge(
    var.tags,
    { Name = "${var.app_name}-${var.env}-tgw-ram" }
  )
}

resource "aws_ram_principal_association" "dev" {
  principal          = "351277498040" # devアカウントのID
  resource_share_arn = aws_ram_resource_share.this.arn
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = [<subnet-id-1>, <subnet-id-2>]
  transit_gateway_id = "tgw-0bcfdde6ac5e2575d"
  vpc_id             = <dev-vpc-id>
}
