###############################################
# Outputs
# 利用者が上位モジュールから参照する必要がある最小限の値のみを公開します。
###############################################

output "vpc_id" {
  description = "作成された疑似オンプレ VPC の ID。VPN 接続設定などで参照します。"
  value       = aws_vpc.this.id
}

output "subnet_id" {
  description = "strongSwan インスタンスが存在するパブリックサブネットの ID。追加リソース配置時に使用します。"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "strongSwan EC2 インスタンスの ID。SSM 接続や監視設定で参照可能です。"
  value       = aws_instance.cgw.id
}

output "eip" {
  description = "strongSwan インスタンスに割り当てられた Elastic IP アドレス。VPN の対向設定に利用します。"
  value       = aws_eip.cgw.public_ip
}

