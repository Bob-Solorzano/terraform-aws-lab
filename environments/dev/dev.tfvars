########################################
#  Environment Config
########################################
environment = "dev"

########################################
#  Network Config
########################################

# Primary VPC definition
vpc_name = "primary"
vpc_cidr = "10.10.0.0/16"

internet_gw_name = "primary"

# Availability Zones used for this environment.
availability_zones = [
  "us-west-2a",
  "us-west-2b"
]

# CIDR List for Public subnets
# To host:
# - Internet-facing Load Balancers
# - Bastion Hosts
# - NAT Gateways

public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

# CIDR list for Private subnets
# To host:
# - EC2 application servers
# - Internal services

private_subnet_cidrs = [
  "10.10.11.0/24",
  "10.10.12.0/24"
]

# Dedicated database subnets, separate from application-private subnets.
database_subnet_cidrs = [
  "10.10.21.0/24",
  "10.10.22.0/24"
]

#############################################
# Security Settings
#############################################

# Security Group names and descriptions:
security_groups = {

  alb = {
    name        = "alb-sg"
    description = "Application Load Balancer"
  }

  web = {
    name        = "web-sg"
    description = "Apache Web Servers"
  }

  db = {
    name        = "db-sg"
    description = "Database Servers"
  }

  api_lambda = {
    name        = "api-lambda-sg"
    description = "Lambda functions for the inventory API"
  }

}




# SG Ingress Rules
ingress_sg_rules = {
  alb_http = {
    security_group = "alb",      # security group
    rule_type      = "cidr",     # specify this as cidr or sg rule.
    cidr           = "0.0.0.0/0" # CIDR IPV4
    port           = "80",       # To and From ports
    protocol       = "tcp"       # IP Protocol
  }
  web_from_alb = {
    security_group        = "web", # security group
    rule_type             = "sg",  # specify this as cidr or sg rule.
    source_security_group = "alb"  # Reference Security Groups
    port                  = "80",  # To and From ports
    protocol              = "tcp"  # IP Protocol
  }
  db_from_lambda = {
    security_group        = "db",        # security group
    rule_type             = "sg",        # specify this as cidr or sg rule.
    source_security_group = "api_lambda" # Reference Security Groups
    port                  = "5432",      # To and From ports - PostgreSQL port
    protocol              = "tcp"        # IP Protocol
  }
}

egress_sg_rules = {
  db_all_out = {
    security_group = "db"
    rule_type      = "cidr"
    cidr           = "0.0.0.0/0"
    protocol       = "-1"
  }
  web_all_out = {
    security_group = "web"
    rule_type      = "cidr"
    cidr           = "0.0.0.0/0"
    protocol       = "-1"
  }
  lambda_all_out = {
    security_group = "api_lambda"
    rule_type      = "cidr"
    cidr           = "0.0.0.0/0"
    protocol       = "-1"
  }
  alb_http_out = {
    security_group             = "alb"
    rule_type                  = "sg"
    destination_security_group = "web"
    protocol                   = "tcp"
    from_port                  = 80
    to_port                    = 80
} }


########################################################
# Load Balancer Configuration
########################################################
# ALB Names
alb_name = "web"

# Load Balancer Target Group
lb_port     = "80"
lb_protocol = "HTTP"

########################################################
# AutoScaling Configuration
########################################################

