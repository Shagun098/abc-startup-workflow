#############################################
# ecs.tf
#
# PURPOSE:
# - Run short-lived batch processing tasks
# - Triggered by Step Functions
# - Task exits automatically after execution
#############################################

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

# ECS Task Definition (batch-style)
resource "aws_ecs_task_definition" "processor" {
  family                   = "${var.project_name}-processor"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  # Reuse single IAM role
  execution_role_arn = var.iam_role_arn
  task_role_arn      = var.iam_role_arn

  # Container definition
  container_definitions = jsonencode([
    {
      name      = "processor"
      image     = var.ecs_container_image
      essential = true

      # Task runs, waits briefly, then exits
      command = [
        "sh",
        "-c",
        "echo ECS task completed successfully && sleep 10"
      ]
    }
  ])
}