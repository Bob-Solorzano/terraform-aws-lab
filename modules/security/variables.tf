variable "environment" {
  type = string
}

variable "availability_zones" {
  description = "Availability zones used by subnets within the VPC."
  type        = list(string)
}
variable "vpc_id" {
  type = string
}

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

  default = {}
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