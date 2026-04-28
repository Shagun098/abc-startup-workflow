#############################################
# iam.tf
#
# PURPOSE:
# - Reuse ONE IAM role everywhere
# - Attach it to EC2 using an instance profile
#############################################

# IAM instance profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"

  # Extract role name from the ARN
  role = split("/", var.iam_role_arn)[1]
}