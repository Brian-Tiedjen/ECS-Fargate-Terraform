output "alb_sg_id" {
  value = aws_security_group.alb_public_group.id
}

output "ecs_service_sg_id" {
  value = aws_security_group.ecs_service_sg.id
}
