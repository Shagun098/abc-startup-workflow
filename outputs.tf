#############################################
# outputs.tf
#
# PURPOSE:
# - Expose useful resource identifiers
# - Helps with validation, debugging, and reuse
#############################################

# ------------------------
# Networking outputs
# ------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.main.id
}

output "security_group_id" {
  description = "Security group ID used by EC2 and ECS"
  value       = aws_security_group.main.id
}

# ------------------------
# Compute outputs
# ------------------------

output "ec2_instance_id" {
  description = "EC2 instance ID for pre-processing step"
  value       = aws_instance.preprocess.id
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.processor.arn
}

# ------------------------
# Orchestration outputs
# ------------------------

output "step_function_arn" {
  description = "Step Functions state machine ARN"
  value       = aws_sfn_state_machine.workflow.arn
}

# ------------------------
# Storage outputs
# ------------------------

output "s3_bucket_name" {
  description = "S3 bucket used for transaction uploads"
  value       = aws_s3_bucket.transactions.bucket
}