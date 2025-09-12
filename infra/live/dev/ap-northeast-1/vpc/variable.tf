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

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "private_subnet_count_per_az" {
  type    = number
  default = 2
}

variable "subnet_newbits" {
  type    = number
  default = 8
}
