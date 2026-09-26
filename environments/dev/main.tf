provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "terraform-aws-labs"
      Environment = "dev"
      Owner       = "bob"
      ManagedBy   = "terraform"
      CostCenter  = "lab"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  # Global Variables
  environment        = var.environment
  availability_zones = var.availability_zones

  # VPC Variable
  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  internet_gw_name = var.internet_gw_name

  # Subnet Variables
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security" {
  # Global Variables
  environment        = var.environment
  availability_zones = var.availability_zones

  source = "../../modules/security"

  # Security Groups
  security_groups = var.security_groups
  vpc_id          = module.vpc.vpc_id

  # SG Ingress Rules
  ingress_sg_rules = var.ingress_sg_rules
  egress_sg_rules  = var.egress_sg_rules
}

module "alb" {
  # Global Variables
  environment        = var.environment
  availability_zones = var.availability_zones

  # Variables for lb_target group
  vpc_id      = module.vpc.vpc_id
  source      = "../../modules/alb"
  lb_port     = var.lb_port
  lb_protocol = var.lb_protocol

  #Variables for alb
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id

  #Variables for listener
  alb_name = var.alb_name
}

######################################################
#  Compute module build
######################################################
data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "compute" {
  source = "../../modules/compute"

  environment = var.environment

  ami_id = data.aws_ssm_parameter.amazon_linux.value

  instance_type = var.instance_type

  target_group_arn = module.alb.alb_target_group_arn

  private_subnet_ids = module.vpc.private_subnet_ids

  vpc_security_group_ids = [
    module.security.web_security_group_id
  ]

  #Auto scaling group assignment.
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size         = var.asg_max_size
  asg_min_size         = var.asg_min_size
}