#############################################
# stepfunctions.tf
#
# UPDATED PURPOSE:
# 1. Start EC2 Instance
# 2. Wait for EC2 Initialization
# 3. Validate Instance State
# 4. Run ECS Transaction Task
# 5. Final Notification/Success
#############################################

resource "aws_sfn_state_machine" "workflow" {
  name     = var.step_function_name
  role_arn = var.iam_role_arn

  depends_on = [
    aws_instance.preprocess,
    aws_ecs_task_definition.processor
  ]

  definition = jsonencode({
    StartAt = "StartEC2Instance"
    States = {

      # STEP 1: Start the EC2 Instance
      StartEC2Instance = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:startInstances"
        Parameters = {
          InstanceIds = [aws_instance.preprocess.id]
        }
        Next = "WaitForEC2"
      }

      # STEP 2: Wait for 30 seconds to allow booting
      WaitForEC2 = {
        Type    = "Wait"
        Seconds = 30
        Next    = "ValidateEC2Status"
      }

      # STEP 3: Check if the instance is actually "running"
      ValidateEC2Status = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:describeInstances"
        Parameters = {
          InstanceIds = [aws_instance.preprocess.id]
        }
        OutputPath = "$.Reservations[0].Instances[0].State.Name"
        Next = "VerifyState"
      }

      # Logical Branch: Ensure we only proceed if Running
      VerifyState = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$"
            StringEquals = "running"
            Next = "RunECSTransaction"
          }
        ]
        Default = "ValidationFailed"
      }

      # STEP 4: Execute the actual transaction via ECS
      RunECSTransaction = {
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
        Next = "FinalStatus"
      }

      # STEP 5: Final logic to wrap up the workflow
      FinalStatus = {
        Type   = "Pass"
        Result = "Workflow Completed Successfully"
        End    = true
      }

      # Error Handling State
      ValidationFailed = {
        Type    = "Fail"
        Cause   = "EC2 Instance failed to reach running state."
        Error   = "EC2NotRunningError"
      }
    }
  })
}
