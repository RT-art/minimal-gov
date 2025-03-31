output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc-practice-terraform.id 
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.subnet-practice-terraform.id
}

