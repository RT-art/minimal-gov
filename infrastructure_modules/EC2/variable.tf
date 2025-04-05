# SG

variable "sg_name" {
  type        = string
  description = "Name tag for the Security Group."
  default     = "security-group-practice-terraform"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the Security Group will be created."
  # No default, must be provided by composition layer (from network module output)
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks for the ingress rules (HTTP, HTTPS, SSH)."
  default     = ["0.0.0.0/0"]
}

# EC2

variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance."
  default     = "rt-practice-terraform"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  # No default, must be provided by composition layer
}

variable "ami_ssm_parameter_name" {
  type        = string
  description = "Name filter for the AWS AMI data source (e.g., 'amzn2023-ami-hvm-*-x86_64-gp2')."
  # No default, must be provided by composition layer
}

variable "instance_key_name" {
  type        = string
  description = "Name of the key pair to use for the instance."
  # No default, must be provided by composition layer
}

variable "docker_image_name" {
  type        = string
  description = "Docker image name to be used in user data script."
  # No default, must be provided by composition layer
}

variable "subnet_id" {
  type        = string
  description = "ID of the Subnet to launch the instance in."
  # No default, must be provided by composition layer (e.g., from network module output)
}

variable "eip_name_tag_filter" {
  type        = string
  description = "The Name tag value used to filter the existing EIP."
  default     = "rt-practice-eip"
}

variable "user_data_template_path" {
  type        = string
  description = "Path to the user data template file (e.g., 'templates/setup-docker.sh.tpl')."
  default     = "templates/setup-docker.sh.tpl" # モジュール内の相対パスを想定
}

variable "tags" {
  description = "A map of additional tags to assign to the instance and potentially related resources."
  type        = map(string)
  default     = {}
}