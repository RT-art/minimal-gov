# プロバイダのAZ一覧を取得
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # 抜き出したAZのリストから、0番目からvar.az_count分だけ取得
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # iに上で指定したAZ数を代入。vpcのcidrを５分割して、i番目のsubnetを取得
  subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 5, i)]

  # iは0,1.2..でazはap-northeast-1a,ap-northeast-1c...のようにマップ
  subnet_map = { for i, az in local.azs : az => local.subnet_cidrs[i] }
}