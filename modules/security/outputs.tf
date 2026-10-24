##########################################
# Security Group ID's Outputs
##########################################

output "alb_security_group_id" {
  value = aws_security_group.this["alb"].id
}

output "web_security_group_id" {
  value = aws_security_group.this["web"].id
}

output "db_security_group_id" {
  value = aws_security_group.this["db"].id
}

output "lambda_security_group_id" {
  value = aws_security_group.this["api_lambda"].id
}
