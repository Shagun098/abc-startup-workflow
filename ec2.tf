#############################################
# ec2.tf
#
# PURPOSE:
# - EC2 instance representing the
#   "pre-processing" step in the workflow
# - Validated by Step Functions before
#   running ECS processing tasks
#############################################

resource "aws_instance" "preprocess" {
  # Amazon Machine Image for the instance
  ami = var.ec2_ami

  # Instance size kept small for cost efficiency
  instance_type = var.ec2_instance_type

  # Place EC2 in the application subnet
  subnet_id = aws_subnet.main.id

  # Attach security group for internal VPC access
  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  # Attach the single shared IAM role
  # NOTE: EC2 requires an instance profile
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Resource tagging for identification
  tags = {
    Name = "${var.project_name}-preprocess-ec2"
  }
}
