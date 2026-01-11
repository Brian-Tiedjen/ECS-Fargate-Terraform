module "vpc" {
  source          = "../../modules/vpc"
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "logs" {
  source      = "../../modules/logs"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "security" {
  source       = "../../modules/security"
  vpc_id       = module.vpc.vpc_id
  service_port = var.service_port
}

module "alb" {
  source            = "../../modules/alb"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  logs_bucket_name  = module.logs.alb_logs_bucket_name
}

module "iam" {
  source      = "../../modules/iam"
  environment = var.environment
}

module "ecr" {
  source          = "../../modules/ecr"
  environment     = var.environment
  repository_name = "${var.environment}-app"
}

module "ecs" {
  source             = "../../modules/ecs"
  environment        = var.environment
  region             = var.region
  container_image    = "${module.ecr.repository_url}:latest"
  container_port     = var.container_port
  desired_count      = var.desired_count
  task_cpu           = var.task_cpu
  task_memory        = var.task_memory
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.ecs_service_sg_id]
  target_group_arn   = module.alb.target_group_arn
  execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  log_group_name     = module.logs.app_log_group_name
}
