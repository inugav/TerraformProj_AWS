

##################################################################
# Gather data from AWS - Initial
##################################################################

#Get Network setup for the project - currently parsing the statefile in Network-Setup Folder - Local State file
data "terraform_remote_state" "networking" {
  /*  backend = "local"
  config = {
    path = "${path.module}\\..\\NetworkSetup\\terraform.tfstate.d\\${terraform.workspace}\\terraform.tfstate"
  }*/
  backend = "s3"
  config = {
    bucket = "myiacprojadmin"
    key    = "env:/${terraform.workspace}/terraformstate/NetworkSetup.tfstate"
    region = var.region
  }
}
# Get list of AMI Images
data "aws_ami" "ami_linux_list" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# Get list of AMI Images for NAT instances 
data "aws_ami" "ami_natinstance_list" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#Get DNZ Zone
data "aws_route53_zone" "mydnszone" {
  #name = "${var.project_tag}.com"
  zone_id      = data.terraform_remote_state.networking.outputs.dns_zone_info.zone_id
  private_zone = true
}


##################################################################
# Gather data from AWS - Post Creation of Instances
##################################################################
#data "aws_instances" "web_instances" {
#  instance_tags = local.common_tags
#  filter {
#    name   = "instance.group-name"
#    values = [aws_security_group.websrvr_sg.name]
#  }
#  depends_on = [aws_autoscaling_group.websrvr_asg]
#}