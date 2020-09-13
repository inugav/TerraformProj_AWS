#For setting up the bucket

#New Bucket for IaC Project
resource "aws_s3_bucket" "s3bucket_newproj" {
  bucket = "myiacprojs3001"
  tags   = { Project = "${var.project_tag}" }
}