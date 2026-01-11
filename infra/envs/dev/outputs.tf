output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "alb_url" {
  value = module.alb.alb_url
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
