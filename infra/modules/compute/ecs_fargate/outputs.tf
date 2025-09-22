output "ecs_cluster_id" {
  value = module.ecs.cluster_id
}

output "ecs_service_name" {
  value = module.ecs.services[var.service_name].name
}

output "task_definition_arn" {
  value = module.ecs.services[var.service_name].task_definition_arn
}

output "ecs_security_group_id" {
  value = module.ecs_sg.security_group_id
}
