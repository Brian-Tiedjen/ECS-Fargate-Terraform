output "alarm_topic_arn" {
  description = "SNS topic ARN for monitoring alarms"
  value       = aws_sns_topic.alarms.arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = "${var.dashboard_name}-${var.environment}-ecs-dashboard"
}
