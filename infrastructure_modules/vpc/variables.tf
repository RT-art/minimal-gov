variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC and associated resources."
  default     = "vpc-practice-terraform" #呼び出し元で指定がない場合にこの値が使われる
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC."
  # no default, must be provided by composition layer
}

variable "subnet_cidr_block" {
  type        = string
  description = "The CIDR block for the public subnet."
  # no default, must be provided by composition layer
}

variable "availability_zone" {
  type        = string
  description = "The Availability Zone for the public subnet."
  # no default, must be provided by composition layer
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}