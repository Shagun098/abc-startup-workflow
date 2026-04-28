#############################################
# s3.tf
#
# PURPOSE:
# - Application S3 bucket for transaction files
# - Triggers Step Functions on object upload
#############################################

# ----------------------------------------
# S3 Bucket for transaction uploads
# ----------------------------------------
resource "aws_s3_bucket" "transactions" {
  # Bucket used as the entry point for the workflow
  bucket        = var.s3_bucket_name

  # Allow Terraform destroy without manual cleanup
  force_destroy = true
}

# ----------------------------------------
# Enable EventBridge notifications for S3
#
# NOTE:
# - This allows S3 events to be sent to EventBridge
# - No Lambda or custom notification required
# ----------------------------------------
resource "aws_s3_bucket_notification" "eventbridge" {
  bucket      = aws_s3_bucket.transactions.id
  eventbridge = true
}

# ----------------------------------------
# EventBridge Rule
#
# Triggers when an object is uploaded to the
# transaction S3 bucket
# ----------------------------------------
resource "aws_cloudwatch_event_rule" "s3_trigger" {
  name = "${var.project_name}-s3-trigger"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [
          aws_s3_bucket.transactions.bucket
        ]
      }
    }
  })
}

# ----------------------------------------
# EventBridge Target
#
# Starts the Step Functions workflow
# using the single shared IAM role
# ----------------------------------------
resource "aws_cloudwatch_event_target" "stepfunction_target" {
  rule      = aws_cloudwatch_event_rule.s3_trigger.name
  target_id = "StartStepFunction"

  # Step Functions state machine ARN
  arn = aws_sfn_state_machine.workflow.arn

  # Single IAM role reused across services
  role_arn = var.iam_role_arn
}