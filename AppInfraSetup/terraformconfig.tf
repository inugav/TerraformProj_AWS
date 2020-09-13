##################################################################
# Establish connection to AWS
##################################################################
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}
terraform {
  backend "s3" {
    bucket         = "myiacprojadmin"
    key            = "terraformstate/AppInfrastp_DEV.tfstate"
    region         = "ap-south-1" #Variables are not allowed here
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

# We will not manage the S3 Bucket housing state file thru terraform 
/*resource "aws_s3_bucket" "s3bucket_terraformstate" {
  bucket = "myiacprojadmin"
  tags   = { Project = "${var.project_tag}" }
}*/

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}