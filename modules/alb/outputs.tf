#  ALB ARN
output "alb_arn" {
  value = aws_lb.this.arn
}

#  ALB DNS
output "alb_dns" {
  value = aws_lb.this.dns_name
}

#  ALB Zone ID
output "alb_zone_id" {
  value = aws_lb.this.zone_id
}

#  Target Group ARN
output "alb_target_group_arn" {
  value = aws_lb_target_group.this.arn
}

#  Target Group Name
output "alb_target_group_name" {
  value = aws_lb_target_group.this.name
}
