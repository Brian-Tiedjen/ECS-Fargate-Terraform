#Create SNS Topic for alarms
resource "aws_sns_topic" "alarms" {
  name = var.alarm_topic_name != "" ? var.alarm_topic_name : "${var.environment}-monitoring-alarms"

  tags = {
    Name        = "${var.environment}-monitoring-alarms"
    Environment = var.environment
  }
}

#Create SNS Email Subscriptions
resource "aws_sns_topic_subscription" "email_subscriptions" {
  for_each  = toset(var.alarm_email_subscriptions)
  protocol  = "email"
  topic_arn = aws_sns_topic.alarms.arn
  endpoint  = each.value

  depends_on = [aws_sns_topic.alarms]
}

#Create ALB 5xx Errors Alarm
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${var.environment}-alb-5xx-errors"
    Environment = var.environment
  }
}

#Create ALB Unhealthy Host Count Alarm
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.environment}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnhealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

  tags = {
    Name        = "${var.environment}-alb-unhealthy-hosts"
    Environment = var.environment
  }
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

  tags = {
    Name        = "${var.environment}-ecs-cpu-alarm"
    Environment = var.environment
  }
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

  tags = {
    Name        = "${var.environment}-ecs-memory-alarm"
    Environment = var.environment
  }
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

          tags = {
            Name        = var.dashboard_name != "" ? var.dashboard_name : "${var.environment}-dashboard"
            Environment = var.environment
        } }
      }
    ]
  })


}
