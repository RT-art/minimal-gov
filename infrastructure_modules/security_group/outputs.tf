# infrastructure_modules/security_group/outputs.tf

output "security_group_id" {
  description = "The ID of the created Security Group."
  value       = module.sg.security_group_id
}