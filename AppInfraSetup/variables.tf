# This file contains the variable declarations to be used in resources.tf & outout.tf
#Secrets
#variable "aws_access_key" {}
#variable "aws_secret_key" {}
#variable "private_key_path" {}
#variable "key_name" {}

# AWS Global
variable "region" {}
variable "project_tag" {}
locals {
  common_tags = {
    Project     = var.project_tag
    Environment = terraform.workspace
  }
}

#instance variables
variable "env_type" {}
variable "instance_size" {}
variable "instance_min_count" {}
variable "instance_max_count" {}



