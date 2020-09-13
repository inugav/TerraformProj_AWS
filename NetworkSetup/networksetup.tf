# This is the primary code that will call AWS for creating the required resources


##################################################################
# Basic Validations before starting 
##################################################################
# Ensure Environment is DEV / UAT / PRD only
resource "null_resource" "env_check" {
  count= contains(var.env_list,var.env_type)==true ? 0:1
  #"ERROR: The env_type value can only be: DEV, QA or PRD " = true
  provisioner "local-exec" {
    command="echo 'ERROR: The env_type value can only be: DEV, QA or PRD' ; exit 1"
  }
}

#Ensure az_count is between 1 - 4
resource "null_resource" "az_count_check" {
  count=contains(range(1,4),var.az_count)== true ? 0:1
  #"ERROR: The supported az_count is only between 1-4 " = true
  provisioner "local-exec" {
    command="echo 'ERROR: The supported az_count is only between 1-4 ' ; exit 1"
  }
}


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
  cidr_block = var.cidr_env[var.env_type][count.index]
  #cidr_block = cidrsubnet (var.vpc_cidr,4, count.index * var.cidr_env_incr[var.env_type])
  #cidr_block = cidrsubnet (var.cidr_env[var.env_type],2,count.index)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(local.common_tags,{ Name = "${var.env_type}-private-AZ${count.index + 1}-subnet" })
}
resource "aws_subnet" "subnets_public" { 
  count      = var.az_count 
  vpc_id     = aws_vpc.vpc.id

  cidr_block = var.cidr_env[var.env_type][length(var.cidr_env[var.env_type]) - (count.index + 1) ]
  #cidr_block = cidrsubnet (var.vpc_cidr,4, (count.index + var.az_count) * var.cidr_env_incr[var.env_type])
  #cidr_block = cidrsubnet (var.cidr_env[var.env_type],2,"${count.index + var.az_count}")
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(local.common_tags,{ Name = "${var.env_type}-public-AZ${count.index + 1}-subnet" })
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