#Logging
#Create CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/app/${var.environment}-application-logs"
  retention_in_days = 90
  tags = {
    Name        = "${var.environment}-app-logs"
    Environment = var.environment
  }
}

#Create CloudTrail SNS Topic
resource "aws_sns_topic" "cloudtrail" {
  name = "${var.environment}-cloudtrail-sns"
  tags = {
    Name        = "${var.environment}-cloudtrail-sns"
    Environment = var.environment
  }
}

#Allow CloudTrail to publish to SNS
data "aws_iam_policy_document" "cloudtrail_sns" {
  statement {
    sid     = "AllowCloudTrailPublish"
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [aws_sns_topic.cloudtrail.arn]
  }
}

resource "aws_sns_topic_policy" "cloudtrail" {
  arn    = aws_sns_topic.cloudtrail.arn
  policy = data.aws_iam_policy_document.cloudtrail_sns.json
}

#Create CloudTrail logging
resource "aws_cloudtrail" "demo_cloudtrail_logs" {
  name                          = "${var.environment}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.logs_bucket.bucket
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  sns_topic_name                = aws_sns_topic.cloudtrail.name
  tags = {
    Name        = "${var.environment}-cloudtrail"
    Environment = var.environment
  }

  depends_on = [aws_s3_bucket_policy.logs_bucket_policy, aws_sns_topic_policy.cloudtrail]
}

#Create VPC Flow Logs Log Group
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "vpc/${var.environment}-vpc-flow-logs"
  retention_in_days = 90
  tags = {
    Name        = "${var.environment}-vpc-flow-logs"
    Environment = var.environment
  }
}
#Create VPC Flow Logs (REJECT only to reduce costs)
resource "aws_flow_log" "vpc_rejects" {
  vpc_id          = var.vpc_id
  traffic_type    = "REJECT"
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn    = aws_iam_role.vpc_flow_role.arn
  tags = {
    Name        = "${var.environment}-vpc-flow-rejects"
    Environment = var.environment
  }
}

#Create S3 Logs Bucket (ALB + CloudTrail)
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "${var.environment}-logs-bucket-${random_string.random_string_ec2.result}"
  tags = {
    Name        = "${var.environment}-logs-bucket"
    Environment = var.environment
  }
  force_destroy = true


}

#Block Public Access on Logs Bucket
resource "aws_s3_bucket_public_access_block" "block_public_s3" {
  bucket                  = aws_s3_bucket.logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
#Enable Logs Bucket Versioning
resource "aws_s3_bucket_versioning" "logs_bucket_versioning" {
  bucket = aws_s3_bucket.logs_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#Create Logs Bucket Lifecycle Policy
resource "aws_s3_bucket_lifecycle_configuration" "logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

#Create Random String for Bucket Name Uniqueness
resource "random_string" "random_string_ec2" {
  length  = 6
  special = false
  upper   = false
  lower   = true
}

#Set Logs Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "logs_bucket_ownership_controls" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#Enable Logs Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_bucket_sse" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Create S3 Bucket Policy for ALB and CloudTrail
resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ALB access logs
      {
        Sid    = "ALBAccessLogs"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.alb_service_account.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs_bucket.arn}/alb/*"
      },

      # CloudTrail ACL check
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logs_bucket.arn
      },

      # CloudTrail write access
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
