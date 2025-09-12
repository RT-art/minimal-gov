variable "env" {
  type = string
}

variable "app_name" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "services" {
  type    = list(string)
  default = []
}

variable "vpc_cidr" {
  type = string
}
