#############################################
# variables.tf
#
# PURPOSE:
# - Central definition for all configurable
#   inputs used across the infrastructure
# - Keeps values consistent and reusable
#############################################

# ------------------------
# General configuration
# ------------------------

# AWS region where all resources are created
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

# Common prefix used for naming and tagging
variable "project_name" {
  type    = string
  default = "abc-startup"
}

# ------------------------
# Networking
# ------------------------

# CIDR range for the VPC
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# CIDR range for the public subnet
variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

# ------------------------
# EC2 (Pre-processing step)
# ------------------------

# AMI used for the pre-processing EC2 instance
variable "ec2_ami" {
  type    = string
  default = "ami-05d2d839d4f73aafb"
}

# Instance size for EC2 (kept small for cost efficiency)
variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

# ------------------------
# ECS (Processing step)
# ------------------------

# Name of the ECS cluster
variable "ecs_cluster_name" {
  type    = string
  default = "abc-startup-cluster"
}

# CPU units assigned to the ECS task
variable "ecs_task_cpu" {
  type    = string
  default = "256"
}

# Memory (MiB) assigned to the ECS task
variable "ecs_task_memory" {
  type    = string
  default = "512"
}

# Container image used by ECS (public ECR, stable tag)
variable "ecs_container_image" {
  type    = string
  default = "public.ecr.aws/nginx/nginx:stable"
}

# ------------------------
# IAM (Single role reused everywhere)
# ------------------------

# One IAM role reused by:
# - GitHub Actions
# - EC2 instance
# - ECS task
# - Step Functions
# - EventBridge
variable "iam_role_arn" {
  type    = string
  default = "arn:aws:iam::952365420082:role/GitHubActions-IaC-Deployer"
}

# ------------------------
# Step Functions
# ------------------------

# Name of the Step Functions state machine
variable "step_function_name" {
  type    = string
  default = "abc-startup-workflow"
}

# ------------------------
# S3 (Transaction input)
# ------------------------

# Application S3 bucket used for data uploads
# NOTE: Must be globally unique
variable "s3_bucket_name" {
  type        = string
  default     = "2472851-usecase-bucket"
  description = "Bucket used to upload transaction files"
}