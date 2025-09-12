output "vpc_id" {
  description = "ID of the simulated on-prem VPC"
  value       = module.onprem_sim.vpc_id
}

output "subnet_id" {
  description = "ID of the public subnet hosting the strongSwan instance"
  value       = module.onprem_sim.subnet_id
}

output "instance_id" {
  description = "ID of the strongSwan EC2 instance"
  value       = module.onprem_sim.instance_id
}

output "eip" {
  description = "Elastic IP assigned to the strongSwan instance"
  value       = module.onprem_sim.eip
}
