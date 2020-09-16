# This a terraform config file for getting the output values post implementation

##################################################################################
# OUTPUT
##################################################################################

output "websrvr_elb_details" {
  value = {
    arn                       = aws_elb.websrvr_elb.availability_zones,
    Name                      = aws_elb.websrvr_elb.name,
    Instances                 = aws_elb.websrvr_elb.instances,
    dns_name                  = aws_elb.websrvr_elb.dns_name,
    cross_zone_load_balancing = aws_elb.websrvr_elb.cross_zone_load_balancing,
    availability_zones        = aws_elb.websrvr_elb.availability_zones
  }
}

output "webserver_asg_info" {
  value = {
    arn  = aws_autoscaling_group.websrvr_asg.arn,
    id   = aws_autoscaling_group.websrvr_asg.id,
    name = aws_autoscaling_group.websrvr_asg.name
  }
}
output "webinstances" {
  value = {
    ids           = data.aws_instances.web_instances.ids,
    private_ips   = data.aws_instances.web_instances.private_ips
    public_ips    = data.aws_instances.web_instances.public_ips
    instance_tags = data.aws_instances.web_instances.instance_tags
  }
}
output "natinstances" {
  value = {
    ids           = aws_instance.nat_instances[*].id,
    private_ips   = aws_instance.nat_instances[*].private_ip
    public_ips    = aws_instance.nat_instances[*].public_ip
    instance_tags = aws_instance.nat_instances[*].tags
  }
}
output "dbinstances" {
  value = {
    ids           = aws_instance.db_instances[*].id,
    private_ips   = aws_instance.db_instances[*].private_ip
    public_ips    = aws_instance.db_instances[*].public_ip
    instance_tags = aws_instance.db_instances[*].tags
  }
}

output "aws_elb_public_dns" {
  value = aws_elb.websrvr_elb.dns_name
} 