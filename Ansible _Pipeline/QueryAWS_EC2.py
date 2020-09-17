import boto3
import json
strregion = "ap-south-1"
proj = 'my-IaC-Proj-'
commonparms = "ansible_user=ec2-user" # ansible_connection=ssh"
ec2 = boto3.resource(service_name='ec2', region_name=(strregion))

allinsts = []
srvrgrp = set()
for ins in ec2.instances.all():
    if ins.state['Name'] != 'terminated':
        instdet = dict()
        instdet["security_group"] = ins.security_groups[0]['GroupName'] # Assuming only one SG is added to host
        instdet["private_ip"] = ins.private_ip_address
        instdet["public_ip"] = ins.public_ip_address
        srvrgrp.add(((ins.security_groups[0]['GroupName']).replace(proj,"")).replace("_sg",""))
        allinsts.append(instdet)
pvtinvfile = open("hostsfilepvtips.ini","w")
pblinvfile = open("hostsfile.ini","w")
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
pvtinvfile.close()
pblinvfile.close()

