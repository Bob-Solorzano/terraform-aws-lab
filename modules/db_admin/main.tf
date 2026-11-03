resource "aws_security_group" "this" {
  name        = "${var.environment}-db-admin-sg"
  description = "Temporary SSM admin host; no inbound access."
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-db-admin-sg"
    Environment = var.environment
    Tier        = "management"
  }
}

# SSM, CloudWatch, and package installation use HTTPS through the existing
# private-subnet NAT route. PostgreSQL egress is restricted to the RDS SG.
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.this.id
  description       = "HTTPS egress for Systems Manager and CloudWatch."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "postgres" {
  security_group_id            = aws_security_group.this.id
  description                  = "PostgreSQL egress to the RDS security group."
  referenced_security_group_id = var.database_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_admin" {
  security_group_id            = var.database_security_group_id
  description                  = "PostgreSQL access from the temporary SSM admin host."
  referenced_security_group_id = aws_security_group.this.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
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

resource "aws_iam_role" "this" {
  name               = "${var.environment}-db-admin-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Environment = var.environment
    Tier        = "management"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ec2/${var.environment}/db-admin"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    Tier        = "management"
  }
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    sid       = "WriteAdminHostLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:DescribeLogStreams", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.this.arn}:*"]
  }

  statement {
    sid       = "WriteAdminHostMetrics"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["CWAgent"]
    }
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "${var.environment}-db-admin-cloudwatch"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.environment}-db-admin-profile"
  role = aws_iam_role.this.name
}

locals {
  cloudwatch_agent_config = {
    agent = {
      metrics_collection_interval = 60
      run_as_user                 = "root"
    }
    metrics = {
      namespace = "CWAgent"
      metrics_collected = {
        mem = {
          measurement = ["mem_used_percent"]
        }
        disk = {
          measurement = ["used_percent"]
          resources   = ["/"]
        }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/cloud-init.log"
              log_group_name  = aws_cloudwatch_log_group.this.name
              log_stream_name = "{instance_id}/cloud-init"
            },
            {
              file_path       = "/var/log/cloud-init-output.log"
              log_group_name  = aws_cloudwatch_log_group.this.name
              log_stream_name = "{instance_id}/cloud-init-output"
            },
            {
              file_path       = "/var/log/messages"
              log_group_name  = aws_cloudwatch_log_group.this.name
              log_stream_name = "{instance_id}/messages"
            },
            {
              file_path       = "/var/log/amazon/ssm/amazon-ssm-agent.log"
              log_group_name  = aws_cloudwatch_log_group.this.name
              log_stream_name = "{instance_id}/ssm-agent"
            }
          ]
        }
      }
    }
  }
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user_data/bootstrap.sh.tftpl", {
    cloudwatch_agent_config = jsonencode(local.cloudwatch_agent_config)
  })

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.environment}-db-admin"
    Environment = var.environment
    Tier        = "management"
    Temporary   = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm,
    aws_iam_role_policy.cloudwatch,
    aws_cloudwatch_log_group.this
  ]
}
