import boto3
import json
strregion = "ap-south-1"
proj = 'my-IaC-Proj-'
commonparms = "ansible_user=ec2-user" # ansible_connection=ssh"
ec2 = boto3.resource(service_name='ec2', region_name=(strregion))

allinsts = []
srvrgrp = set()
strjumpsrvr = ""
for ins in ec2.instances.all():
#    if ins.state['Name'] != 'terminated':
    if ins.state['Name'] == 'running':
        instdet = dict()
        instdet["security_group"] = ins.security_groups[0]['GroupName'] # Assuming only one SG is added to host
        instdet["private_ip"] = ins.private_ip_address
        instdet["public_ip"] = ins.public_ip_address
        sg=((ins.security_groups[0]['GroupName']).replace(proj,"")).replace("_sg","")
        srvrgrp.add(sg)
        allinsts.append(instdet)
        if (sg.find("natsrvr") >= 0 ) and (len(strjumpsrvr) == 0):
            strjumpsrvr = ins.public_ip_address

pvtinvfile = open("./hostsfilepvtips.ini","w")
pblinvfile = open("./hostsfile.ini","w")
pvtinvfile.write("[all:children]\n")
pblinvfile.write("[all:children]\n")

for sg in srvrgrp:
    pvtinvfile.write(sg+"\n" )
    pblinvfile.write(sg+"\n" )

for sg in srvrgrp:
    pvtinvfile.write("\n["+sg+"]\n")
    pblinvfile.write("\n["+sg+"]\n")
    i=1
    for inst in allinsts:
        if inst['security_group'] == proj+sg+"_sg":
            tmp = sg+"_"+str(i)
            pvtinvfile.write(tmp + " " + "ansible_host="+inst['private_ip'] + " " + commonparms + "\n")
            if (inst['public_ip'] is not None):
                pblinvfile.write(tmp + " " + "ansible_host="+inst['public_ip']+ " " + commonparms + "\n")
            i=i+1
            
# Update Vars for DB Server for connection Proxy
strsshline = 'ansible_ssh_common_args=\'-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -A -q ec2-user@'
for sg in srvrgrp:
    pvtinvfile.write("\n["+sg+":vars]\n")
    pblinvfile.write("\n["+sg+":vars]\n" )
    
    if sg.find('dbsrvr') == 0 :
        pvtinvfile.write(strsshline + strjumpsrvr +"\"'")

pvtinvfile.close()
pblinvfile.close()

