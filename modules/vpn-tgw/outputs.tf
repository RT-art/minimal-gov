###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
# 利用方法のヒントをコメントとして併記します。
###############################################

output "customer_gateway_id" {
  description = "作成された Customer Gateway の ID。例: CloudWatch ログや別 VPN 設定の参照に利用。"
  value       = aws_customer_gateway.this.id
}

output "vpn_connection_id" {
  description = "作成された Site-to-Site VPN 接続 ID。例: VPN ログの有効化やルートテーブル関連付けに利用。"
  value       = aws_vpn_connection.this.id
}

output "tunnel1_address" {
  description = "AWS 側トンネル 1 のエンドポイント IP。オンプレデバイス設定時に利用します。"
  value       = aws_vpn_connection.this.tunnel1_address
}

output "tunnel2_address" {
  description = "AWS 側トンネル 2 のエンドポイント IP。オンプレデバイス設定時に利用します。"
  value       = aws_vpn_connection.this.tunnel2_address
}

