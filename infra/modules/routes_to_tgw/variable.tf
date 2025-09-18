variable "route_table_ids" {
  description = "TGWルートを追加する Route Table のID一覧"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "Transit Gateway のID"
  type        = string
}

variable "destination_cidr_block" {
  description = "宛先CIDRブロック (デフォルトは全トラフィック)"
  type        = string
  default     = "0.0.0.0/0"
}
