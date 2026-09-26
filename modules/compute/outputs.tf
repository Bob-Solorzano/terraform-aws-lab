# Autoscaling Group Name
output "autoscaling_group_name" {
  value = aws_autoscaling_group.this.name
}

# Launch Template ID
output "launch_template_id" {
  value = aws_launch_template.web.id
}

# Launch Template Latest Version
output "launch_template_latest_version" {
  value = aws_launch_template.web.latest_version
}

# IAM Role Name
output "iam_role_name" {
  value = aws_iam_role.web.name
}

# Instance Profile Name
output "instance_profile_name" {
  value = aws_iam_instance_profile.web.name
}