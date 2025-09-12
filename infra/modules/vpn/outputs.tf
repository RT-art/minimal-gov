output "customer_gateway_id" {
  description = "Customer Gateway ID"
  value       = aws_customer_gateway.this.id
}

output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = aws_vpn_connection.this.id
}

output "vpn_connection_tunnel1_address" {
  description = "Public IP address of the first VPN tunnel"
  value       = aws_vpn_connection.this.tunnel1_address
}

output "vpn_connection_tunnel2_address" {
  description = "Public IP address of the second VPN tunnel"
  value       = aws_vpn_connection.this.tunnel2_address
}
