###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
# 各出力の利用方法のヒントをコメントとして併記します。
###############################################

output "tgw_id" {
  description = "作成した TGW の ID。例: VPC/VPN アタッチメント作成時の transit_gateway_id に指定。"
  value       = aws_ec2_transit_gateway.this.id
}

output "tgw_arn" {
  description = "作成した TGW の ARN。監視/参照用途で必要な場合に使用。"
  value       = aws_ec2_transit_gateway.this.arn
}

output "rt_user_id" {
  description = "ユーザ向け TGW ルートテーブルの ID。例: ユーザ VPN アタッチメントの関連付け先に指定。"
  value       = aws_ec2_transit_gateway_route_table.user.id
}

output "rt_spoke_to_network_id" {
  description = "Spoke→Network 復路用 TGW ルートテーブルの ID。例: Prod/Dev 側アタッチメントの伝播/関連付け設定に使用。"
  value       = aws_ec2_transit_gateway_route_table.spoke_to_network.id
}

output "rt_network_to_spoke_id" {
  description = "Network→Spoke 往路用 TGW ルートテーブルの ID。例: Network VPC アタッチメントの関連付け先に使用。"
  value       = aws_ec2_transit_gateway_route_table.network_to_spoke.id
}

