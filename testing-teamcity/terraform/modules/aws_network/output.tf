output "region" {
  value = var.region
}



output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
/*
output "web_loadbalancer_url" {
  value = aws_elb.web[*].dns_name
}
*/
output "aws_subnet_natted" {
  value = aws_subnet.natted[*].id
}


output "bastion_aws_eip_eip_subnet_routed_public_dns" {
  value = aws_eip.eip_subnet_routed.public_dns
}
/*
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}



output "eip_routed-stuff" {
  value = aws_eip.eip_subnet_routed-stuff.public_dns
}

output "eip_routed" {
  value = aws_eip.eip_subnet_routed.public_dns
}
*/
