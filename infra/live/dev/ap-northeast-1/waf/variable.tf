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

variable "name" {
  type = string
}

variable "allow_cidrs" {
  type = list(string)
}
