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

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "task_cpu" {
  type = number
}

variable "task_memory" {
  type = number
}

variable "allowed_cidrs" {
  type = list(string)
}

variable "health_check_path" {
  type    = string
  default = "/"
}
