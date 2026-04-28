# Use AWS as the cloud provider
# Authentication is handled via GitHub OIDC (no keys here)
provider "aws" {
  region = "ap-south-1"   # Region where all resources will be created
}