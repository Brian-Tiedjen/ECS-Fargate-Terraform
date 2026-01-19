#
resource "aws_ecr_repository" "app" {
  name = var.repository_name
  image_tag_mutability = "IMMUTABLE"

    lifecycle {
    prevent_destroy = true
    }
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment}-ecr"
    Environment = var.environment
  }
}
