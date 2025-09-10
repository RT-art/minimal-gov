###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
# 各出力の利用方法のヒントをコメントとして併記します。
###############################################

output "attachment_id" {
  description = "作成した VPC アタッチメントの ID。例: ルートテーブル関連付け/伝播リソースの入力に利用。"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "attachment_arn" {
  description = "作成した VPC アタッチメントの ARN。監視/参照用途で必要な場合に使用。"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.arn
}

output "vpc_id" {
  description = "アタッチされた VPC の ID。例: 他モジュール連携時の整合性チェックに使用。"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.vpc_id
}

output "transit_gateway_id" {
  description = "接続先 TGW の ID。例: 複数アタッチメント間の関連付け時の参照に使用。"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway_id
}

output "subnet_ids" {
  description = "アタッチメントで使用したサブネット IDs。例: AZ ごとの可用性確認などに利用。"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.subnet_ids
}

