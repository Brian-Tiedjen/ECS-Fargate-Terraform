#Security Group for ECS service tasks
resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.environment}-ecs-service-sg"
  description = "Security group for ECS service tasks"
  vpc_id      = var.vpc_id

  # CKV_AWS_23: rule descriptions required
  ingress {
    description     = "Allow ALB ingress to ECS service"
    from_port       = var.service_port
    to_port         = var.service_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_public_group.id]
  }
  # CKV_AWS_23: rule descriptions required
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Security Group for ALB
resource "aws_security_group" "alb_public_group" {
  name        = "${var.environment}-alb-public-sg"
  description = "Security group for public ALB"
  vpc_id      = var.vpc_id

  # CKV_AWS_23: rule descriptions required
  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = var.alb_ingress_port
    to_port     = var.alb_ingress_port
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }
  # CKV_AWS_23: rule descriptions required
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
