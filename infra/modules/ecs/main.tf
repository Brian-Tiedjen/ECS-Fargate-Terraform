#Create ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}
#ECS Task Definition
resource "aws_ecs_task_definition" "first_ecs_task" {
  family                   = "${var.environment}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.container_image
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.environment
        }
      }
      environment = [
        {
          name  = "APP_VERSION"
          value = var.app_version
        }
      ]
    }
  ])

  tags = {
    Name        = "${var.environment}-task"
    Environment = var.environment
  }
}

#Create ECS Service
resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.first_ecs_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  #auto rollback
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = {
    Name        = var.service_name
    Environment = var.environment
  }
}

#Auto Scaling Configuration
#Create ECS Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_service" {
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  depends_on = [aws_ecs_service.service]
}

#Create ECS CPU Target Tracking Policy
resource "aws_appautoscaling_policy" "ecs_cpu_target" {
  name               = "${var.service_name}-cpu"
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.ecs_service]
}

#Create ECS Memory Target Tracking Policy
resource "aws_appautoscaling_policy" "ecs_memory_target" {
  name               = "${var.service_name}-memory"
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.ecs_service]
}
