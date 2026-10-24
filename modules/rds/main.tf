resource "aws_db_subnet_group" "this" {
  name        = "${var.environment}-database"
  description = "Database subnets for the ${var.environment} environment."
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${var.environment}-database"
    Environment = var.environment
    Tier        = "database"
  }
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = "postgres"
  instance_class = var.instance_class
  db_name        = var.database_name
  username       = var.master_username

  manage_master_user_password = true

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.vpc_security_group_id]
  publicly_accessible    = false

  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
  delete_automated_backups   = true
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : var.final_snapshot_identifier

  apply_immediately = false

  tags = {
    Name        = var.identifier
    Environment = var.environment
    Tier        = "database"
  }

  lifecycle {
    precondition {
      condition     = var.skip_final_snapshot || var.final_snapshot_identifier != null
      error_message = "Set final_snapshot_identifier when skip_final_snapshot is false."
    }
  }
}
