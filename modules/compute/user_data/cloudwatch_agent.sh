#!/bin/bash

# Setting to propagate failures back to bootstrap.sh.
set -euo pipefail

echo "Starting CloudWatch Agent installation"


########################################
# Install CloudWatch Agent
########################################

echo "Installing CloudWatch Agent"

if command -v dnf >/dev/null 2>&1; then
    dnf install amazon-cloudwatch-agent -y
elif command -v yum >/dev/null 2>&1; then
    yum install amazon-cloudwatch-agent -y
else
    echo "ERROR: Unsupported Linux distribution"
    exit 1
fi


########################################
# Create CloudWatch Agent Configuration
########################################

echo "Creating CloudWatch Agent configuration"

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc


cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CWAgent",

    "metrics_collected": {

      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },

      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "/"
        ]
      },

      "diskio": {
        "measurement": [
          "io_time",
          "write_bytes",
          "read_bytes"
        ],
        "resources": [
          "*"
        ]
      },

      "swap": {
        "measurement": [
          "swap_used_percent"
        ]
      }

    }
  },
    "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/bootstrap.log",
            "log_group_name": "/aws/ec2/bootstrap",
            "log_stream_name": "{instance_id}/bootstrap"
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "/aws/ec2/cloud-init",
            "log_stream_name": "{instance_id}/cloud-init"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "/aws/ec2/cloud-init-output",
            "log_stream_name": "{instance_id}/cloud-init-output"
          },
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/httpd",
            "log_stream_name": "{instance_id}/access"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/httpd",
            "log_stream_name": "{instance_id}/error"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/system",
            "log_stream_name": "{instance_id}/messages"
          }
        ]
      }
    }
  }
}
EOF


########################################
# Start CloudWatch Agent
########################################

echo "Starting CloudWatch Agent"

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s


########################################
# Enable on reboot
########################################

echo "Enabling CloudWatch Agent service"

systemctl enable amazon-cloudwatch-agent


########################################
# Verify service
########################################

echo "Checking CloudWatch Agent status"

systemctl is-active amazon-cloudwatch-agent


echo "CloudWatch Agent installation completed successfully"

exit 0