
output "alb_logs_bucket_name" {
  description = "S3 bucket storing ALB access logs"
  value       = aws_s3_bucket.logs_bucket.bucket
}
output "logs_bucket_name" {
  value = aws_s3_bucket.logs_bucket.bucket
}

output "app_log_group_name" {
  description = "CloudWatch log group for application logs"
  value       = aws_cloudwatch_log_group.app.name
}
