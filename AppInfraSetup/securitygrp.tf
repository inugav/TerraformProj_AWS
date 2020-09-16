## Web Application - Security Group Inbound & Outbound config
resource "aws_security_group" "websrvr_sg" {
  name = "${var.project_tag}-websrvr_${terrafom.workspace}_sg"
  ingress { #Allow HTTP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { #Allow HTTPS
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Allow SSH Inbound
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_info.id
  tags   = merge({ Project = "${var.project_tag}" }, { Name = "${var.project_tag}-websrvr_${terrafom.workspace}_sg" })
}

#NAT Instance Security Group
resource "aws_security_group" "natinst_sg" {
  name = "${var.project_tag}-natsrvr_${terrafom.workspace}_sg"
  # SSH access 
  ingress { # Allow from public network
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP & HTTPS access from Private Network only
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.networking.outputs.private_subnet_list[*].cidr_block
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.networking.outputs.private_subnet_list[*].cidr_block
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_info.id
  tags   = merge({ Project = "${var.project_tag}" }, { Name = "${var.project_tag}-natsrvr_${terrafom.workspace}_sg" })
}

### Database servers security group
resource "aws_security_group" "mysql-sg" {
  name = "${var.project_tag}-dbsrvr_${terrafom.workspace}_sg"

  # MySQL access from Web & NAT Instance Only
  ingress {
    from_port = 1433
    to_port   = 1433
    protocol  = "tcp"
    #cidr_blocks = 
    security_groups = [aws_security_group.natinst_sg.id]
  }
  ingress {
    from_port = 1433
    to_port   = 1433
    protocol  = "tcp"
    #cidr_blocks = aws_elb.websrvr_elb.subnets 
    security_groups = [aws_security_group.websrvr_sg.id]
  }
  # SSH access from NAT Instance Only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.natinst_sg.id] #Instead of CIDR Blocks
  }

  # outbound open access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_info.id
  tags   = merge({ Project = "${var.project_tag}" }, { Name = "${var.project_tag}-dbsrvr_${terrafom.workspace}_sg" })
}
