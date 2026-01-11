output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.cluster.name
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.service.name
}

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.task.arn
}
