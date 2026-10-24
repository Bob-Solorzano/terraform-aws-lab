variable "environment" {
  description = "Environment name used for resource names and tags."
  type        = string
}

variable "identifier" {
  description = "Unique RDS instance identifier."
  type        = string
}

variable "database_name" {
  description = "Name of the initial PostgreSQL database."
  type        = string
  default     = "inventory"
}

variable "master_username" {
  description = "Master username; RDS manages its password in Secrets Manager."
  type        = string
  default     = "dbadmin"
}

variable "instance_class" {
  description = "RDS instance class for this environment."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial database storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage in GiB for RDS storage autoscaling."
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Whether to create a Multi-AZ standby for the database."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether to prevent accidental deletion of the database."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when destroying the database."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Snapshot identifier to use when skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Private database subnet IDs spanning at least two Availability Zones."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two database subnets in separate Availability Zones."
  }
}

variable "vpc_security_group_id" {
  description = "Security group allowed to connect to the database."
  type        = string
}
