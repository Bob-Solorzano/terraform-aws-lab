##########################################
# VPC/Network Outputs
##########################################
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the isolated database subnets"
  value       = module.vpc.database_subnet_ids
}

##########################################
# ALB Outputs
##########################################
# ALB Arn
output "alb_arn" {
  value = module.alb.alb_arn
}

#  ALB DNS
output "alb_dns" {
  value = module.alb.alb_dns
}

#  ALB Zone ID
output "alb_zone_id" {
  value = module.alb.alb_zone_id
}

#  Target Group ARN
output "alb_target_group_arn" {
  value = module.alb.alb_target_group_arn
}

#  Target Group Name
output "alb_target_group_name" {
  value = module.alb.alb_target_group_name
}

##########################################
# Compute
##########################################
# Autoscaling Group Name
output "autoscaling_group_name" {
  value = module.compute.autoscaling_group_name
}

# Launch Template ID
output "launch_template_id" {
  value = module.compute.launch_template_id
}

# Launch Template Latest Version
output "launch_template_latest_version" {
  value = module.compute.launch_template_latest_version
}

# IAM Role Name
output "iam_role_name" {
  value = module.compute.iam_role_name
}

# Instance Profile Name
output "instance_profile_name" {
  value = module.compute.instance_profile_name
}

##########################################
# Security Group ID's Outputs
##########################################

output "alb_security_group_id" {
  value = module.security.alb_security_group_id
}

output "web_security_group_id" {
  value = module.security.web_security_group_id
}

output "db_security_group_id" {
  value = module.security.db_security_group_id
}

output "lambda_security_group_id" {
  value = module.security.lambda_security_group_id
}

output "database_identifier" {
  value = module.rds.identifier
}

output "database_address" {
  value = module.rds.address
}

output "database_endpoint" {
  value = module.rds.endpoint
}

output "database_port" {
  value = module.rds.port
}

output "database_name" {
  value = module.rds.database_name
}

output "database_master_user_secret_arn" {
  value = module.rds.master_user_secret_arn
}
