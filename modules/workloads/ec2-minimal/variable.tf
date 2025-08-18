variable "env" { type = string }
variable "app_name" { type = string }
variable "region" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
