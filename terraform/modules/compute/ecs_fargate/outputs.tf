output "ecs_cluster_id" {
  value = var.enable_ecs ? module.ecs[0].cluster_id : null
}

output "ecs_service_name" {
  value = var.enable_ecs ? module.ecs[0].services[local.service_name].name : null
}

output "task_definition_arn" {
  value = var.enable_ecs ? module.ecs[0].services[local.service_name].task_definition_arn : null
}

output "ecs_security_group_id" {
  value = module.ecs_sg.security_group_id
}
