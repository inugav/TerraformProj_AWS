# This is the primary code for DB servers that will call AWS for creating the required resources

##################################################################
# Setup Database Server Environment & Required Infrastructure on AWS  
##################################################################

#Install NAT Server Instance
resource "aws_instance" "nat_instances" {
  count                       = length(data.terraform_remote_state.networking.outputs.public_subnet_list) # One per AZ
  ami                         = data.aws_ami.ami_natinstance_list.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.natinst_sg.id]
  associate_public_ip_address = true
  subnet_id                   = data.terraform_remote_state.networking.outputs.public_subnet_list[count.index].id
  tags                        = merge(local.common_tags, { Name = "${terraform.workspace}_NATSrvr_${count.index}" })
}

#Install MYSQL DB Server Instance
resource "aws_instance" "db_instances" {
  count                       = var.instance_max_count[terraform.workspace]["DB"]
  ami                         = data.aws_ami.ami_linux_list.id
  instance_type               = var.instance_size[terraform.workspace]["WEB"]
  subnet_id                   = data.terraform_remote_state.networking.outputs.private_subnet_list[count.index].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.mysql-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.dbsrvr_iam_profile.name
  user_data                   = file("./templates/dbsrvr_userdata.sh") #Install mysql on Launch
  tags                        = merge(local.common_tags, { Name = "${terraform.workspace}_DBSrvr_${count.index}" })
  associate_public_ip_address = false
}

#Cloud Watch Alarm for DB Server Down
resource "aws_cloudwatch_metric_alarm" "dbsrvr-down" {
  count                     = length(aws_instance.db_instances)
  alarm_name                = "${var.project_tag}-${terraform.workspace}-db_down-${count.index}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "EC2 Status Check"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.db_instances[count.index].id
  }
}

######## Route 53 Actions ##############

#Route53 Health Check for DB Servers
resource "aws_route53_health_check" "dbsrvr" {
  count                           = length(aws_instance.db_instances)
  type                            = "CLOUDWATCH_METRIC"
  cloudwatch_alarm_name           = aws_cloudwatch_metric_alarm.dbsrvr-down[count.index].alarm_name
  cloudwatch_alarm_region         = var.region
  insufficient_data_health_status = "Unhealthy"
  tags                            = merge(local.common_tags, { Name = "${var.project_tag}-${terraform.workspace}-dbsrv_HC-${count.index}" })
}

# Create A Records for host 
resource "aws_route53_record" "dbsrvr_dnsrecord" {
  count   = length(aws_instance.db_instances)
  zone_id = data.aws_route53_zone.mydnszone.zone_id
  name    = "${count.index == 0 ? "primary" : "secondary"}_dbsrvr.${data.aws_route53_zone.mydnszone.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.db_instances[count.index].private_ip]
}

#Create Alias for the host 
resource "aws_route53_record" "dbsrvr_aliasdns" {
  count   = length(aws_instance.db_instances)
  zone_id = data.aws_route53_zone.mydnszone.zone_id
  name    = "dbsrvr.${data.aws_route53_zone.mydnszone.name}"
  type    = "A"
  failover_routing_policy {
    type = count.index == 0 ? "PRIMARY" : "SECONDARY"
  }
  set_identifier = "${count.index == 0 ? "PRIMARY" : "SECONDARY"}_db"
  alias {
    name                   = aws_route53_record.dbsrvr_dnsrecord[count.index].name
    zone_id                = aws_route53_record.dbsrvr_dnsrecord[count.index].zone_id
    evaluate_target_health = true
  }
  health_check_id = aws_route53_health_check.dbsrvr[count.index].id
}


