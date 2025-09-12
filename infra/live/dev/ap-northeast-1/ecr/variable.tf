variable "env" {
  type = string
}

variable "app_name" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "keep_last_images" {
  type    = number
  default = 10
}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "pull_principal_arns" {
  type    = list(string)
  default = []
}
