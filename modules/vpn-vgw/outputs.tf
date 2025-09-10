###############################################
# Outputs from vpn-vgw module
###############################################

# 作成された VGW の ID
# - ルートテーブルへの伝播設定など、上位モジュールでの参照に利用
output "vgw_id" {
  description = "作成された VGW の ID"
  value       = aws_vpn_gateway.this.id
}

# 作成された VPN Connection の ID
# - 監視設定や追加ルート登録時に参照
output "vpn_connection_id" {
  description = "作成された VPN 接続 ID"
  value       = aws_vpn_connection.this.id
}

