variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "vpc_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "availability_zones" {
  description = "Availability zones used by subnets within the VPC."
  type        = list(string)
}

# Public subnets
variable "public_subnet_cidrs" {
  description = "CIDR blocks used to create public subnets within the VPC."
  type        = list(string)
}

# Internet Gateway
variable "internet_gw_name" {
  description = "Name of Internet gateway."
  type        = string
}

#NAT Gateway
variable "enable_nat_gateway" {
  type    = bool
  default = false
}

# private subnets
variable "private_subnet_cidrs" {
  description = "CIDR blocks used to create private subnets within the VPC."
  type        = list(string)
}