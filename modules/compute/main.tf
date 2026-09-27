#IAM Instance Profile
resource "aws_iam_instance_profile" "web" {
  name = "${var.environment}_iam_web_profile"
  role = aws_iam_role.web.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "web" {
  name               = "${var.environment}_web_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attache SSM permissions to the IAM Role
resource "aws_iam_role_policy_attachment" "ssm" {

  role = aws_iam_role.web.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attache CloudWatch policy to the IAM Role
resource "aws_iam_role_policy_attachment" "cloudwatchagent" {

  role = aws_iam_role.web.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attache S3 Full privs to the IAM Role
resource "aws_iam_role_policy_attachment" "s3" {

  role = aws_iam_role.web.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

##########################################
# Launch Template.
##########################################

resource "aws_launch_template" "web" {
  name = "web"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted = true
      delete_on_termination = true
    }
  }

# Limit EC2 from being stopped by API, console, ...
  #  disable_api_stop        = true

  # Limit EC2 from being stopped by API, console, ...
#  disable_api_termination = true

  # Most recent EBS Volumes already include this.
 # ebs_optimized = true

  #IAM Profile assignment
  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }

  image_id = var.ami_id

  # For Autoscale, instances should be terminated on shutdown
  instance_initiated_shutdown_behavior = "terminate"

  ##########CAUTION #####################
  # Past free tier, this allows low cost for labs... NOT FOR PROD...
  instance_market_options {
    market_type = "spot"
  }

  instance_type = var.instance_type

  #Manual Kernal Override
#  kernel_id = "test"

  # Only needed for Licensed environments...
#  license_specification {
#    license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
#  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Increase Cloudwatch monitoring to every 1 min.  Override 5 minute default
#  monitoring {
#    enabled = true
#  }

  # Create and manage Network Interface  Address???
#  network_interfaces {
#    associate_public_ip_address = true
#  }

  # Hardcode the templates to a specific AZ... Already using multi AZ in subnets.
#  placement {
#    availability_zone = "us-west-2a"
#  }

  #Specify a specific RAM Disk ID
#  ram_disk_id = "test"

  vpc_security_group_ids = var.vpc_security_group_ids

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "dev-web"
    }
  }

  user_data = base64encode(
    templatefile("${path.module}/user_data/bootstrap.sh", {
      httpd_script          = file("${path.module}/user_data/httpd.sh")
      cloudwatch_script     = file("${path.module}/user_data/cloudwatch_agent.sh")
    })
  )
#  user_data = filebase64("${path.module}/user_data/bootstrap.sh")
#  user_data = filebase64("./httpd.sh")
#  user_data = var.user_data
}

resource "aws_autoscaling_group" "this" {
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity   = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size

  target_group_arns = [var.target_group_arn]
  health_check_type = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 0
    }
  }
}
