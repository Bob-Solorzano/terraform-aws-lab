output "identifier" {
  description = "RDS DB instance identifier."
  value       = aws_db_instance.this.identifier
}

output "address" {
  description = "RDS DNS hostname."
  value       = aws_db_instance.this.address
}

output "endpoint" {
  description = "RDS endpoint in hostname:port format."
  value       = aws_db_instance.this.endpoint
}

output "port" {
  description = "PostgreSQL port."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial PostgreSQL database name."
  value       = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the RDS-managed master credentials."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}
