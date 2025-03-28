output "elastic_ip_address" {
  description = "割り当てられた Elastic IP アドレスを表示"
  value       = aws_eip.eip_for_instance.public_ip
}