#Create VPC
module "vpc" {
  source          = "../../modules/vpc"
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

#Create Logging
module "logs" {
  source      = "../../modules/logs"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

#Create Security Groups
module "security" {
  source            = "../../modules/security"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  service_port      = var.service_port
  alb_ingress_port  = var.alb_listener_port
  alb_ingress_cidrs = var.alb_ingress_cidrs
}

#Create Application Load Balancer
module "alb" {
  source            = "../../modules/alb"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  logs_bucket_name  = module.logs.alb_logs_bucket_name
}

#Create IAM Roles
module "iam" {
  source      = "../../modules/iam"
  environment = var.environment
}

#Create ECR Repository
module "ecr" {
  source          = "../../modules/ecr"
  environment     = var.environment
  repository_name = "${local.name_prefix}-app"
}

#Create ECS Service
module "ecs" {
  source              = "../../modules/ecs"
  environment         = var.environment
  region              = var.region
  container_image     = "${module.ecr.repository_url}:${var.image_tag}"
  container_port      = var.container_port
  desired_count       = var.desired_count
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  cpu_target_value    = var.cpu_target_value
  memory_target_value = var.memory_target_value
  scale_in_cooldown   = var.scale_in_cooldown
  scale_out_cooldown  = var.scale_out_cooldown
  task_cpu            = var.task_cpu
  task_memory         = var.task_memory
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.ecs_service_sg_id]
  target_group_arn    = module.alb.target_group_arn
  execution_role_arn  = module.iam.task_execution_role_arn
  task_role_arn       = module.iam.task_role_arn
  log_group_name      = module.logs.app_log_group_name
  cluster_name        = "${local.name_prefix}-cluster"
  service_name        = "${local.name_prefix}-service"
  app_version         = var.image_tag
}
