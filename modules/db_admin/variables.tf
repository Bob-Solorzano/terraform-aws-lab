variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the admin host and database reside."
  type        = string
}

variable "subnet_id" {
  description = "Private application subnet for the temporary admin host."
  type        = string
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID."
  type        = string
}

variable "database_security_group_id" {
  description = "RDS security group, which accepts PostgreSQL from this host only."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size for the temporary admin host."
  type        = string
  default     = "t3.micro"
}
