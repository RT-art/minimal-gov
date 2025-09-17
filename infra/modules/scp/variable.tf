# scp
variable "add_scps" {
  description = "追加で作成・アタッチする SCP の一覧"
  type = map(object({
    description = string
    file        = string # applyした時の/policies/以下のファイル名
    target_id   = string # アタッチ先 OU / Account ID
  }))
  default = {}
}

variable "custom_policies_dir" {
  description = "add_scps で参照するカスタムポリシーファイルを配置したディレクトリ"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}