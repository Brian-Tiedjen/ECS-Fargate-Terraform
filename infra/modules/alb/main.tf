#Create Application Load Balancer
resource "aws_lb" "alb_public" {
  name               = "${var.environment}-alb-public"
  internal           = false
  load_balancer_type = "application"
  drop_invalid_header_fields = true
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_subnet_ids

  access_logs {
    bucket  = var.logs_bucket_name
    prefix  = "alb"
    enabled = true
  }
  tags = {
    Name        = "${var.environment}-alb-public"
    Environment = var.environment
  }
}


#Create ALB Target Group
resource "aws_lb_target_group" "demo_alb_group" {
  name        = "${var.environment}-alb-target-group"
  target_type = "ip"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name        = "${var.environment}-alb-target-group"
    Environment = var.environment
  }
}


#Create ALB listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb_public.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo_alb_group.arn
  }
}
