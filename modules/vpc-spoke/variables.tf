###############################################
# Variables
# すべての変数に詳細説明を付与します。
###############################################

variable "name_prefix" {
  type        = string
  default     = null
  description = <<-EOT
  リソースの論理名や Name タグに付与するプレフィックス。
  未指定（null/空文字）の場合は "spoke" を用います。

  例: "dev" を指定した場合、VPC 名は "dev-vpc" のようになります。
  EOT
}

variable "vpc_cidr" {
  type        = string
  description = <<-EOT
  VPC の CIDR ブロック（例: "10.0.0.0/16"）。
  本モジュールでは、この CIDR を `cidrsubnet()` で分割し、プライベートサブネットを作成します。
  既存のネットワーク設計と重複しないように注意してください。
  EOT

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr は有効な CIDR 形式で指定してください (例: 10.0.0.0/16)。"
  }
}

variable "azs" {
  type        = list(string)
  description = <<-EOT
  利用するアベイラビリティゾーンのリスト（例: ["ap-northeast-1a", "ap-northeast-1c"]）。
  指定順序に基づいて、サブネットの AZ を割り当てます。
  最低 1 要素を指定してください。
  EOT

  validation {
    condition     = length(var.azs) > 0
    error_message = "azs は 1 つ以上の AZ を含めてください。"
  }
}

variable "private_subnet_count_per_az" {
  type        = number
  description = <<-EOT
  各 AZ に作成するプライベートサブネットの個数。
  例: 3 を指定すると、各 AZ に 3 サブネット（計 AZ 数×3）を作成します。

  注意: 必要以上に細かく分割するとルートテーブル数も増加します。
  小規模では 2～3、拡張性重視で 3～4 が一般的な目安です。
  EOT

  validation {
    condition     = var.private_subnet_count_per_az > 0 && floor(var.private_subnet_count_per_az) == var.private_subnet_count_per_az
    error_message = "private_subnet_count_per_az は 1 以上の整数で指定してください。"
  }
}

variable "subnet_newbits" {
  type        = number
  description = <<-EOT
  `cidrsubnet()` の newbits。VPC CIDR をどれだけ細かく分割するかを指定します。
  例: vpc_cidr=10.0.0.0/16, newbits=8 の場合、各サブネットは /24 となります。

  注意: (AZ 数 × private_subnet_count_per_az) の総サブネット数を生成できる newbits を指定してください。
  EOT

  validation {
    condition     = var.subnet_newbits > 0 && var.subnet_newbits <= 16
    error_message = "subnet_newbits は 1～16 の範囲で指定してください。"
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
  リソースに付与する共通タグ。コンプライアンスやコスト配賦の観点で、
  最低限 Project/Env/Owner などのタグ付与を推奨します。
  EOT
}

