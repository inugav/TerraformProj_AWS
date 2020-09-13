# This is the file that will house the default values for some of the variables and some constants used

#Global
region = "ap-south-1"
project_tag = "my-IaC-Proj"
vpc_cidr = "10.10.0.0/16"
az_count = 2

#Network
cidr_env = {  # 8 Subnets per environment
  DEV = ["10.10.0.0/21","10.10.8.0/21","10.10.16.0/21","10.10.24.0/21","10.10.32.0/21","10.10.40.0/21","10.10.48.0/21", "10.10.56.0/21"]
  UAT = ["10.10.64.0/21","10.10.72.0/21","10.10.80.0/21","10.10.88.0/21","10.10.96.0/21","10.10.104.0/21","10.10.112.0/21", "10.10.120.0/21"]
  PRD = ["10.10.128.0/21","10.10.136.0/21","10.10.144.0/21","10.10.152.0/21","10.10.160.0/21","10.10.168.0/21","10.10.176.0/21", "10.10.184.0/21"]
}

#cidr_env_inct = { 
#  DEV = 1
#  UAT = 4
#  PRD = 8
#}

#Environment 
env_type="DEV"   #Valid types are DEV, UAT, PRD
env_list = ["DEV","UAT","PRD"]