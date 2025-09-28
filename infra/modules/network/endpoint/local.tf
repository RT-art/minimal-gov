locals {
  # Interface / Gateway で注入する既定値を定義
  interface_defaults = {
    vpc_id             = var.vpc_id
    subnet_ids         = var.endpoint_subnet_ids
    security_group_ids = [module.vpce_sg.security_group_id]
  }

  gateway_defaults = {
    vpc_id          = var.vpc_id
    route_table_ids = var.route_table_ids
  }

  # 少し分かり辛いが、interface型ならサブネットとセキュリティグループIDを追加し、gatewayならルートテーブルを追加
  # additional_paramsは、追加のオプションを入力する受け皿
  # 例1: additional_params = {
  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #         Action   = "*"
  #         Effect   = "Allow"
  #         Resource = "*"
  #         Principal = "*"
  #       }
  #     ]
  #
  # 例2:additional_params = {
  #   private_dns_enabled = false
  # }

  normalized_endpoints = {
    for k, v in var.endpoints :
    k => merge(
      v,
      v.service_type == "Interface" ? local.interface_defaults : {},
      v.service_type == "Gateway" ? local.gateway_defaults : {},
      try(v.additional_params, {})
    )
  }
}
