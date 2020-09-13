# Will house all configurations for IAM Roles, Policies & Security Groups

resource "aws_iam_role" "EC2BucketAccess" {
  name               = "EC2BucketAccess_Role"
  path               = "/"
  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
    EOF
  tags               = { Project = "${var.project_tag}" }
}

resource "aws_iam_role_policy_attachment" "s3toEC2" { #attach S3 Full Access Policy to Role
  role       = aws_iam_role.EC2BucketAccess.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "websrvr_iam_profile" {
  lifecycle {
    create_before_destroy = false
  }
  name = "${var.project_tag}_websrvr_iam_profile"
  role = aws_iam_role.EC2BucketAccess.name
}

resource "aws_iam_instance_profile" "dbsrvr_iam_profile" {
  lifecycle {
    create_before_destroy = false
  }
  name = "${var.project_tag}_dbsrvr_iam_profile"
  role = aws_iam_role.EC2BucketAccess.name
}

