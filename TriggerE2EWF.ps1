param ( $env_type = 'DEV')

$AppInfraplanprefix = 'AppInfrastp_'
$Networkplanprefix = 'Networkstp_'
$curdir = pwd
$curdate = get-date -Format "dd_mm_yyyy"
$outfile = $curdir + $env_type + $curdate + ".json"
Write-host 'Current Working Directory - ' $curdir

#Initiate Network setup
Write-host "Initializing Network on AWS"
cd NetworkSetup
Write-host "Initiating Network Setup in $env_type"
try {
    terraform workspace select $env_type
    terraform workspace show | Write-host 'Current Workspace '
    
}
catch
{
    terraform workspace new $env_type
}
$tfplanname = $Networkplanprefix + $env_type + '.tfplan'
terraform init 
terraform plan -out $tfplanname
terraform apply $tfplanname
terraform output -json >  $outfile

#Initiate Application setup
Write-host "Initializing Application Setup on AWS"
cd $curdir
cd 'AppInfraSetup'
Write-host "Initiating Network Setup in $env_type"
try {
    terraform workspace select $env_type
    terraform workspace show | Write-host 'Current Workspace '
    
}
catch
{
    terraform workspace new $env_type
}
$tfplanname = $AppInfraplanprefix + $env_type + '.tfplan'
terraform init 
terraform plan -out $tfplanname
terraform apply $tfplanname
terraform output -json >>  $outfile

cd $curdir
