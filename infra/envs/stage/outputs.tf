output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "alb_url" {
  value = module.alb.alb_url
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "logs_bucket_name" {
  value = module.logs.logs_bucket_name
}

output "ecs_task_execution_role_arn" {
  value = module.iam.task_execution_role_arn
}

output "ecs_task_role_arn" {
  value = module.iam.task_role_arn
}
