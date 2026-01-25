#Security Group for ECS service tasks
resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.environment}-ecs-service-sg"
  description = "Security group for ECS service tasks"
  vpc_id      = var.vpc_id

  egress {
    description     = "Allow HTTPS to VPC interface endpoints"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.vpc_endpoint_sg_id]
  }
  egress {
    description     = "Allow HTTPS to S3 gateway endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [var.s3_prefix_list_id]
  }
  egress {
    description = "Allow DNS over UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    description = "Allow DNS over TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    description = "Allow ECS task metadata endpoint"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["169.254.170.2/32"]
  }
}

#Security Group for ALB
resource "aws_security_group" "alb_public_group" {
  name        = "${var.environment}-alb-public-sg"
  description = "Security group for public ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = var.alb_ingress_port
    to_port     = var.alb_ingress_port
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }
}

resource "aws_security_group_rule" "alb_to_ecs_ingress" {
  description              = "Allow ALB ingress to ECS service"
  type                     = "ingress"
  from_port                = var.service_port
  to_port                  = var.service_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_service_sg.id
  source_security_group_id = aws_security_group.alb_public_group.id
}

resource "aws_security_group_rule" "alb_to_ecs_egress" {
  description              = "Allow ALB to reach ECS tasks"
  type                     = "egress"
  from_port                = var.service_port
  to_port                  = var.service_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_public_group.id
  source_security_group_id = aws_security_group.ecs_service_sg.id
}
