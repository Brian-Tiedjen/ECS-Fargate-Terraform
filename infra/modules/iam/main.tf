#Create IAM assume role policy for ECS tasks
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#Create Task Execution Role
resource "aws_iam_role" "task_execution_role" {
  name               = "${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
  tags = {
    Name        = "${var.environment}-ecs-task-execution-role"
    Environment = var.environment
  }
}

#Attach Default Execution Policy
resource "aws_iam_role_policy_attachment" "task_execution_default" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Attach Extra Execution Policies
resource "aws_iam_role_policy_attachment" "task_execution_extra" {
  for_each   = toset(var.execution_policy_arns)
  role       = aws_iam_role.task_execution_role.name
  policy_arn = each.value
}

#Create Task Role
resource "aws_iam_role" "task_role" {
  name               = "${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
  tags = {
    Name        = "${var.environment}-ecs-task-role"
    Environment = var.environment
  }
}

#Attach Extra Task Policies
resource "aws_iam_role_policy_attachment" "task_extra" {
  for_each   = toset(var.task_policy_arns)
  role       = aws_iam_role.task_role.name
  policy_arn = each.value
}
