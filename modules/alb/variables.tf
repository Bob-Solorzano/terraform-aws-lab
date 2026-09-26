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

variable "vpc_id" {
  type = string
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

# ALB Variables
variable "alb_name" {
  description = "Name of ALB to be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs where ALB will be deployed"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group for the Application load balancer"
  type        = string
}