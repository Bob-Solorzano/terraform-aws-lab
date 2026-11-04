########################################
#  Environment Config
########################################

variable "environment" {
  type = string
}

########################################
#  Network Config
########################################

variable "availability_zones" {
  description = "Availability zones used by subnets within the VPC."
  type        = list(string)
}

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR blocks used to create the VPC."
  type        = string
}

variable "internet_gw_name" {
  description = "Internet gateway."
  type        = string
}

# NAT Gateway
variable "enable_nat_gateway" {
  type    = bool
  default = false
}
# Public subnets
variable "public_subnet_cidrs" {
  description = "CIDR blocks used to create public subnets within the VPC."
  type        = list(string)
}

# Private subnets
variable "private_subnet_cidrs" {
  description = "CIDR blocks used to create private subnets within the VPC."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks used to create isolated database subnets within the VPC."
  type        = list(string)
}

variable "database_name" {
  description = "Name of the initial PostgreSQL database."
  type        = string
  default     = "aws_tools"
}

variable "enable_rds" {
  description = "Whether to create the optional PostgreSQL RDS instance."
  type        = bool
  default     = false
}

variable "database_master_username" {
  description = "Master username for the PostgreSQL instance. RDS manages its password."
  type        = string
  default     = "dbadmin"
}

variable "database_instance_class" {
  description = "RDS instance class for the dev database."
  type        = string
  default     = "db.t3.micro"
}

variable "database_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "database_max_allocated_storage" {
  description = "Maximum RDS storage in GiB for autoscaling."
  type        = number
  default     = 100
}

variable "database_backup_retention_period" {
  description = "Number of days to retain automated database backups."
  type        = number
  default     = 7
}

variable "database_multi_az" {
  description = "Whether to enable Multi-AZ for the dev database."
  type        = bool
  default     = false
}

variable "database_deletion_protection" {
  description = "Whether to prevent accidental deletion of the RDS database."
  type        = bool
  default     = false
}

variable "database_skip_final_snapshot" {
  description = "Whether to skip the final snapshot when destroying the RDS database."
  type        = bool
  default     = true
}

variable "enable_db_admin_host" {
  description = "Whether to create the temporary SSM-managed PostgreSQL administration host."
  type        = bool
  default     = false
}

variable "db_admin_instance_type" {
  description = "EC2 instance type for the temporary database administration host."
  type        = string
  default     = "t3.micro"
}

#  Security Groups Variables
variable "security_groups" {
  description = "Security Groups to create"

  type = map(object({
    name        = string,
    description = string
  }))
}

variable "ingress_sg_rules" {
  description = "Ingress Security Groups rules to create"

  type = map(object({
    security_group = string, # security group

    rule_type             = string,           # specify this as cidr or sg rule.
    source_security_group = optional(string), # source security group .
    cidr                  = optional(string)  # CIDR IPV4

    port     = string, # To and From ports
    protocol = string  # IP Protocol
  }))
}


variable "egress_sg_rules" {
  type = map(object({
    security_group = string

    rule_type = string
    cidr      = optional(string)

    destination_security_group = optional(string)

    from_port = optional(number)
    to_port   = optional(number)

    protocol = string
  }))
}

##########################################
#  Load Balancer Configuration details
##########################################
variable "alb_name" {
  description = "Name of ALB to be deployed"
  type        = string
}

# Target Group Variables
variable "lb_port" {
  description = "Port setting for the load balancer"
  type        = string
}

variable "lb_protocol" {
  description = "Protocol setting for the load balancer"
  type        = string
}

##################################################
# Auto Scaling variables
##################################################
variable "instance_type" {
  description = "Instance Type to use for launch template"
  type        = string
  default     = "t3.micro"
}

# AUTO Scaling Group Variables
variable "asg_desired_capacity" {
  description = "Autoscaling Group desired capacity"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Autoscaling Group Max Size"
  type        = number
  default     = 4
}

variable "asg_min_size" {
  description = "Autoscaling Group Min Size"
  type        = number
  default     = 2
}
