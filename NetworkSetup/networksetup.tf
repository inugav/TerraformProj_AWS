# This is the primary code that will call AWS for creating the required resources



##################################################################
# Gather data from AWS 
##################################################################
data "aws_availability_zones" "available" {} # List availability zones

##################################################################
# Setup Environment & Required Infrastructure on AWS  
##################################################################

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge({Project = "${var.project_tag}"}, { Name = "${var.project_tag}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge({Project = "${var.project_tag}"}, { Name = "${var.project_tag}-igw" })
}

resource "aws_subnet" "subnets_private" {  
  count      = var.az_count  
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.cidr_env[terraform.workspace][count.index]
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(local.common_tags,{ Name = "${terraform.workspace}-private-AZ${count.index + 1}-subnet" })
}
resource "aws_subnet" "subnets_public" { 
  count      = var.az_count 
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.cidr_env[terraform.workspace][length(var.cidr_env[terraform.workspace]) - (count.index + 1) ]
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(local.common_tags,{ Name = "${terraform.workspace}-public-AZ${count.index + 1}-subnet" })
}

resource "aws_route_table" "pbl_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge({Project = "${var.project_tag}"}, { Name = "${var.project_tag}-pbl_rtb" })
}
resource "aws_route_table" "pvt_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = merge({Project = "${var.project_tag}"}, { Name = "${var.project_tag}-pvt_rtb" })
}

resource "aws_route_table_association" "pvt_rta-subnet" {
  count          = var.az_count
  subnet_id      = aws_subnet.subnets_private[count.index].id
  route_table_id = aws_route_table.pvt_rtb.id
}
resource "aws_route_table_association" "pbl_rta-subnet" {
  count          = var.az_count
  subnet_id      = aws_subnet.subnets_public[count.index].id
  route_table_id = aws_route_table.pbl_rtb.id
}

## Create DNS Zone for this project
resource "aws_route53_zone" "private" {
  name = "${lower(var.project_tag)}.com"
  vpc {
    vpc_id = aws_vpc.vpc.id
  }
  tags = {Project = var.project_tag}
}