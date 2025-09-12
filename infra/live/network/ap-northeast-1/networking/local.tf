locals {
  tgw_attachment_subnet_ids = [
    for sn in var.tgw_attachment_subnet_names :
    module.vpc.subnets[sn].id
  ]
  attachment_name = "${var.app_name}-${var.env}-tgw-attach"
}

