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
