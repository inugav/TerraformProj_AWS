## My-IaC-Proj-Terraform
Purpose: 
-------
Terraform Project - For creating AWS environment, with parameters for
  - DEV/UAT/PRD
  - No of Instances
  - Type of Instance
  - Zone / Region
  - No of zones for implementation

Details: 
--------
  - Network Setup : First module that needs to be run. Sets up the required AWS environment. Executed through Jenkins Pipeline
    - VPC
    - Internet Gateway
    - Public & Private subnets
    - Routing Table & its associations
    - DNS Zones
  - AppInfra Setup : Sets up the required instances and other application infrastructure. Executed through Jenkins Pipeline.  
     - Web Servers:
       - ELB
       - Auto Scale
       - Launch Config
       - Group
       - Scaling policy
       - Cloud Watch
       - IAM Roles & Security Groups
     - DB Servers:
       - EC2 Instances
       - DNS Records
       - Cloud Watch & Health Checks
       - IAM Roles & Security Groups
     - NAT Instances
       - EC2 Instance & Security Groups
     - S3 Buckets
   - Ansible Pipeline: Basic Filecopy post discovery of environment
     - Collects Host details and generates Inventory file
     - Copys basic html files to web servers  

How it works: 
-------------
  - Jenkins pipe line is invoked with parameters
    - DEV/ UAT / PROD on AWS Instances.
    - To Build or Destroy the AWS Instances
    - No of Servers, CIDR, Zone, # of Availability Zones to scale to etc are in respective **variables.auto.tfvars
    - Network Setup needs to be invoked first, followed by App Infra setup.
    - Ansible Pipeline is triggered manually. 
    
Points to note: 
---------------
    - Terraform:
       - Installed on same server as Jenkins
       - Workspace configured with State File on AWS S3
       - Terraform 0.12 used
    - Jenkins : 
       - Terraform needs to be configured on Jenkins as plugin
       - Jenkins is on Windows server for this implementation. Calls might need to be modified accordingly.
     - Ansible : 
       - The test uses WSL implementation of Ansible, hence pipeline batch file executions need to be modified accordingly.
       - The discovery code might need tweeking to suite individual needs. 
