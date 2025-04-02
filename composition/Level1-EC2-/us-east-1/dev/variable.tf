# composition/my-app/ap-northeast-1/dev/variables.tf

# --- General Environment Variables ---
variable "env" {
  type        = string
  description = "Environment name (e.g., 'dev', 'stg', 'prod')."
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "app_name" {
  type        = string
  description = "Base name for application resources."
}

# --- VPC Network Variables ---
variable "comp_vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "comp_subnet_cidr_block" {
  type        = string
  description = "CIDR block for the public subnet."
}

variable "comp_availability_zone" {
  type        = string
  description = "Availability Zone for the public subnet."
}

# --- Security Group Variables ---
variable "comp_ingress_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks for the main security group ingress rules."
  default     = ["0.0.0.0/0"] # デフォルトを設定
}

# --- EC2 Compute Variables ---
variable "comp_instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro" # 必要に応じてデフォルト値を設定
}

variable "comp_ami_name_filter" {
  type        = string
  description = "Name filter for the AWS AMI data source."
  default     = "amzn2023-ami-hvm-*-x86_64-gp2" # 例: Amazon Linux 2023
}

variable "comp_instance_key_name" {
  type        = string
  description = "Name of the key pair to use for the instance."
  # No default, should be provided in tfvars
}

variable "comp_docker_image_name" {
  type        = string
  description = "Docker image name for user data script."
  default     = "nginx:latest" # 例
}

variable "comp_instance_name" {
  type        = string
  description = "Name tag for the EC2 instance."
  default     = "rt-practice-terraform-ec2" # Infrastructure側のデフォルトを上書きする場合など
}

variable "comp_eip_name_tag_filter" {
  type        = string
  description = "The Name tag value used to filter the existing EIP for EC2."
  default     = "rt-practice-eip" # Infrastructure側のデフォルトと同じだが、明示的に指定も可能
}

