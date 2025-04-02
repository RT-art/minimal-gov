# infrastructure_modules/compute/outputs.tf

output "instance_id" {
  description = "The ID of the EC2 instance created."
  value       = module.ec2_instance.id
}

output "instance_arn" {
  description = "The ARN of the EC2 instance created."
  value       = module.ec2_instance.arn
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = module.ec2_instance.private_ip
}

output "associated_eip_public_ip" {
  description = "The public IP address of the EIP associated with the instance."
  value       = data.aws_eip.existing_eip.public_ip
}

output "associated_eip_allocation_id" {
  description = "The allocation ID of the EIP associated with the instance."
  value       = data.aws_eip.existing_eip.id
}