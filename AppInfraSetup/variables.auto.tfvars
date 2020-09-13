# This is the file that will house the default values for some of the variables and some constants used

#Global
region      = "ap-south-1"
project_tag = "my-IaC-Proj"
#Environment & Instances
env_type = "DEV"

instance_size = {
  DEV = {
    WEB = "t2.micro"
    DB  = "t2.micro"
  }
  UAT = {
    WEB = "t2.micro"
    DB  = "t2.micro"
  }
  PRD = {
    WEB = "t2.micro"
    DB  = "t2.micro"
  }
}
instance_min_count = {
  DEV = {
    WEB = 2
    DB  = 2
  }
  UAT = {
    WEB = 2
    DB  = 2
  }
  PRD = {
    WEB = 2
    DB  = 2
  }
}
instance_max_count = {
  DEV = {
    WEB = 2
    DB  = 2
  }
  UAT = {
    WEB = 2
    DB  = 2
  }
  PRD = {
    WEB = 2
    DB  = 2
  }
}





