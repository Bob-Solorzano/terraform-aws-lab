terraform {
  required_version = ">= 1.15.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.53.0"
    }
  }

  backend "s3" {
    bucket = "terraform-aws-lab-state-bsolo-1111"
    key    = "terraform-aws-lab/dev/terraform.tfstate"
    region = "us-west-2"
  }
}
