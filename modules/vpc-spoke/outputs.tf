###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみ出力します。
# 利用方法のヒントをコメントとして併記します。
###############################################

output "vpc_id" {
  description = "作成した VPC の ID。例: module.vpc_spoke.vpc_id を TGW アタッチ等の入力に渡す。"
  value       = aws_vpc.this.id
}

output "private_subnet_ids_by_az" {
  description = <<-EOT
  AZ ごとのプライベートサブネット ID 一覧（map）。
  例: for_each で AZ 単位のリソース作成や、AZ 指定のアタッチメントに利用可能。
  フォーマット: { "ap-northeast-1a" = [subnet-xxxx, ...], "ap-northeast-1c" = [...] }
  EOT
  value = {
    for az in var.azs :
    az => [for s in aws_subnet.private : s.id if s.availability_zone == az]
  }
}

output "route_table_ids" {
  description = "作成したルートテーブル IDs（サブネットごとに 1 つ）。例: module.vpc_spoke.route_table_ids で一括参照。"
  value       = [for rt in aws_route_table.private : rt.id]
}

