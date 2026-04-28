#############################################
# backend.tf
#
# PURPOSE:
# - Store Terraform state (terraform.tfstate)
#   in a remote S3 backend
# - Enable safe concurrent execution using
#   S3-based state locking (Terraform ≥ 1.5)
# - Ensure the same state is shared across:
#     • GitHub Actions
#     • Virtual Machines
#     • Local development
#
# IMPORTANT:
# - This S3 bucket must be created manually
# - This bucket must NOT be managed by Terraform
#############################################

terraform {
  backend "s3" {
    # Dedicated S3 bucket for Terraform state
    bucket = "2472851-abc-startup-terraform-state"

    # Path inside the bucket where state is stored
    key = "abc-startup/terraform.tfstate"

    # AWS region where the state bucket exists
    region = "ap-south-1"

    # Encrypt state data at rest
    encrypt = true

    # Use modern S3-native state locking (Terraform >= 1.5)
    # Prevents concurrent apply/destroy corruption
    use_lockfile = true
  }
}
