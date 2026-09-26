variable "environment" {
  type = string
}

variable "ami_id" {
  description = "AMI ID to use for launch template"
  type        = string
}

variable "instance_type" {
  description = "Instance Type to use for launch template"
  type        = string
}

#variable "user_data" {
#  description = "User Data to use for EC2 images in launch template"
#  type        = string
#}
variable "vpc_security_group_ids" {
  description = "List of security Groups to use for launch template"
  type        = list(string)
}

variable "target_group_arn" {
  description = "Target Group to use for launch template"
  type        = string
}

variable "private_subnet_ids" {
  description = "Public Subnet IDs"
  type        = list(string)
}

# AUTO Scaling Group Variables
variable "asg_desired_capacity" {
  description = "Autoscaling Group desired capacity"
  type        = number
}

variable "asg_max_size" {
  description = "Autoscaling Group Max Size"
  type        = number
}

variable "asg_min_size" {
  description = "Autoscaling Group Min Size"
  type        = number
}
