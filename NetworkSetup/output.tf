# This a terraform config file for getting the output values post implementation

##################################################################################
# OUTPUT
##################################################################################

output "azs_configured_on" {
  value = aws_subnet.subnets_public[*].availability_zone
}
output "vpc_info" {
  value = aws_vpc.vpc
}
output "private_subnet_list" {
  value = aws_subnet.subnets_private[*]
}
output "public_subnet_list" {
  value = aws_subnet.subnets_public[*]
}
output "dns_zone_info" {
  value = aws_route53_zone.private
}