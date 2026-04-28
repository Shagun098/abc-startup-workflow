#############################################
# stepfunctions.tf
#
# PURPOSE:
# - Coordinate preprocessing and processing stages
# - Allow ECS execution when EC2 is running
#############################################

resource "aws_sfn_state_machine" "workflow" {
  name     = var.step_function_name
  role_arn = var.iam_role_arn

  depends_on = [
    aws_instance.preprocess,
    aws_ecs_task_definition.processor
  ]

  definition = jsonencode({
    StartAt = "DescribeEC2"

    States = {

      ##################################
      # DescribeEC2
      #
      # Retrieves EC2 instance state
      ##################################
      DescribeEC2 = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:describeInstanceStatus"

        Parameters = {
          InstanceIds         = [aws_instance.preprocess.id]
          IncludeAllInstances = true
        }

        ResultPath = "$.ec2"
        Next       = "ValidateEC2"
      }

      ##################################
      # ValidateEC2
      #
      # Checks only whether the EC2
      # instance is in running state
      ##################################
      ValidateEC2 = {
        Type = "Choice"

        Choices = [{
          Variable     = "$.ec2.InstanceStatuses[0].InstanceState.Name"
          StringEquals = "running"
          Next         = "RunECSTask"
        }]

        Default = "EC2NotRunning"
      }

      ##################################
      # RunECSTask
      #
      # Executes ECS Fargate batch task
      ##################################
      RunECSTask = {
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

      ##################################
      # EC2NotRunning
      #
      # Terminates workflow if EC2
      # is not in running state
      ##################################
      EC2NotRunning = {
        Type  = "Fail"
        Error = "EC2NotRunning"
        Cause = "EC2 instance is not in running state"
      }
    }
  })
}
