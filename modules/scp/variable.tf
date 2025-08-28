variable "allowed_regions" { type = list(string) }
variable "tags" { type = map(string) }

variable "targets" {
  description = "SCPをアタッチする対象のIDマップ"
  type = object({
    root_id     = string
    security_ou = string
    workloads   = string
    prod        = string
    dev         = string
    sandbox     = string
    suspended   = string
  })
}

variable "attach_map" {
  description = <<EOT
各SCPをどのターゲットにアタッチするかを定義。
例:
{
  deny_root                 = ["root_id"]
  deny_leaving_org          = ["root_id"]
  deny_unapproved_regions   = ["root_id"]
  deny_disable_sec_services = ["prod","dev","sandbox"]
}
EOT
  type        = map(list(string))
}
