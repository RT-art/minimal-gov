variable "region" {
  type = string
}

variable "ous" {
  type = set(string)
}

variable "accounts" {
  type = map(object({
    email = string
    ou    = string
  }))
}

variable "allowed_regions" {
  type = list(string)
}

variable "default_tags" {
  type = map(string)
}
