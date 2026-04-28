resource "aws_sfn_state_machine" "workflow" {
  name     = var.step_function_name
  role_arn = var.iam_role_arn

  depends_on = [
    aws_instance.preprocess,
    aws_ecs_task_definition.processor
  ]

  definition = jsonencode({
    StartAt = "Initialize"
    States = {

      # STEP 1: Logical start point for logging/metadata
      Initialize = {
        Type   = "Pass"
        Result = { status = "Starting Workflow" }
        Next   = "StartEC2"
      }

      # STEP 2: Boot the Instance
      StartEC2 = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:startInstances"
        Parameters = {
          InstanceIds = [aws_instance.preprocess.id]
        }
        Next = "WaitReady"
      }

      # STEP 3: Pause for system boot
      WaitReady = {
        Type    = "Wait"
        Seconds = 30
        Next    = "ValidateState"
      }

      # STEP 4: Confirm EC2 is healthy
      ValidateState = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:describeInstances"
        Parameters = {
          InstanceIds = [aws_instance.preprocess.id]
        }
        Next = "RunTransaction"
      }

      # STEP 5: Final ECS Processing
      RunTransaction = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"
        Parameters = {
          LaunchType     = "FARGATE"
          Cluster        = aws_ecs_cluster.main.arn
          TaskDefinition = aws_ecs_task_definition.processor.arn
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = [aws_subnet.main.id]
              SecurityGroups = [aws_security_group.main.id]
              AssignPublicIp = "ENABLED"
            }
          }
        }
        End = true
      }
    }
  })
}
