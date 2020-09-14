# This file contains the variable declarations to be used in resources.tf & outout.tf

# AWS Global
variable "region" {}
variable "az_count" {}
variable "project_tag" {}
locals  { 
    common_tags = {
        Project = var.project_tag
        Environment = var.env_type
    }
}
variable "env_type" {}
variable "env_list" {}

#network variables
variable "vpc_cidr" {}
variable "cidr_env" { }








