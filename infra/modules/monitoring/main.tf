#Create SNS Topic for alarms
resource "aws_sns_topic" "alarms" {
  name = var.alarm_topic_name != "" ? var.alarm_topic_name : "${var.environment}-monitoring-alarms"

}

#Create SNS Email Subscriptions
resource "aws_sns_topic_subscription" "email_subscriptions" {
  for_each  = toset(var.alarm_email_subscriptions)
  protocol  = "email"
  topic_arn = aws_sns_topic.alarms.arn
  endpoint  = each.value
}

#Create ECS CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.period_seconds
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  alarm_name          = "${var.environment}-ecs-cpu-alarm"
  alarm_description   = "Alarm when ECS CPU exceeds ${var.cpu_high_threshold}%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

}

#Create ECS Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.period_seconds
  statistic           = "Average"
  threshold           = var.memory_high_threshold
  alarm_name          = "${var.environment}-ecs-memory-alarm"
  alarm_description   = "Alarm when ECS Memory exceeds ${var.memory_high_threshold}%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

}

#Create ECS CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count          = var.enable_dashboard ? 1 : 0
  dashboard_name = var.dashboard_name != "" ? var.dashboard_name : "${var.environment}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name]
          ]
          period = var.period_seconds
          stat   = "Average"
          region = var.region
          title  = "ECS Service CPU and Memory Utilization"
        }
      }
    ]
  })
}
