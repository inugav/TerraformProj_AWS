# This is the primary code for web servers that will call AWS for creating the required resources

##################################################################$
# Setup Web Server Environment & Required Infrastructure on AWS  
##################################################################
#Install  Web Servers in Public Subnets based on Instance_count in autoscale group
#-----------------------------------------------------------------

# Setup ELB 
resource "aws_elb" "websrvr_elb" {
  name    = "${var.project_tag}-websrvr-elb-${terraform.workspace}"
  subnets = data.terraform_remote_state.networking.outputs.public_subnet_list[*].id
  #availability_zones = data.terraform_remote_state.networking.outputs.azs_configured_on

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  security_groups = [aws_security_group.websrvr_sg.id]
  tags            = local.common_tags
}

#Auto Scaling Group Congiguration 
resource "aws_launch_configuration" "websrvr_lc" { # Define the launch configuration for the web servers
  lifecycle {
    create_before_destroy = true
  }
  name_prefix   = "${terraform.workspace}-${var.project_tag}-web-lc"
  image_id      = data.aws_ami.ami_linux_list.id
  instance_type = var.instance_size[terraform.workspace]["WEB"]
  key_name      = var.key_name
  security_groups = [
    aws_security_group.websrvr_sg.id
  ]
  user_data                   = file("./templates/websrvr_userdata.sh") #Install nginx on Launch
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.websrvr_iam_profile.name
}

resource "aws_autoscaling_group" "websrvr_asg" { ## Auto Scale Group configuration
  lifecycle {
    create_before_destroy = false
  }

  vpc_zone_identifier   = data.terraform_remote_state.networking.outputs.public_subnet_list[*].id
  name                  = "${var.project_tag}_websrvr_asg-${terraform.workspace}"
  max_size              = var.instance_max_count[terraform.workspace]["WEB"]
  min_size              = var.instance_min_count[terraform.workspace]["WEB"]
  wait_for_elb_capacity = var.instance_min_count[terraform.workspace]["WEB"]
  force_delete          = true
  launch_configuration  = aws_launch_configuration.websrvr_lc.id
  load_balancers        = [aws_elb.websrvr_elb.name]

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Scale Up Policy and Alarm
resource "aws_autoscaling_policy" "websrvr_scale_up" {
  name                   = "${var.project_tag}_asg_scale_up-${terraform.workspace}"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.websrvr_asg.name
}

resource "aws_cloudwatch_metric_alarm" "websrvr_scale_up_alarm" {
  alarm_name                = "${var.project_tag}-high-asg-cpu-${terraform.workspace}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.websrvr_asg.name
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = [aws_autoscaling_policy.websrvr_scale_up.arn]
}

# Scale Down Policy and Alarm
resource "aws_autoscaling_policy" "websrvr_scale_down" {
  name                   = "${var.project_tag}_asg_scale_down-${terraform.workspace}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = aws_autoscaling_group.websrvr_asg.name
}

resource "aws_cloudwatch_metric_alarm" "websrvr-scale_down_alarm" {
  alarm_name                = "${var.project_tag}-low-asg-cpu-${terraform.workspace}"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "5"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.websrvr_asg.name
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = [aws_autoscaling_policy.websrvr_scale_down.arn]
} 