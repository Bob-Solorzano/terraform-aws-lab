output "instance_id" {
  description = "EC2 instance ID for starting an SSM session."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IPv4 address of the admin host."
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Security group attached to the admin host."
  value       = aws_security_group.this.id
}
