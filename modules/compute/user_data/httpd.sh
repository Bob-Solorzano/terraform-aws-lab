#!/bin/bash

# Trigger script failure on error
set -e

# Update package metadata
dnf -y update

# Install Apache
dnf -y install httpd

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# Request Token for 6hrs (21600 seconds) and store in TOKEN
TOKEN=$(curl -X PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Validate Token and return EC2 Instance ID.
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

HOSTNAME=$(hostname)

# Validate Token and return EC2 Instances private IP.
PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

# Validate Token and return EC2 Instances AZ.
AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

REGION=${AZ::-1}

cat <<EOF >/var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Terraform AWS Lab</title>
</head>
<body>
    <h1>Terraform AWS Lab</h1>
    <hr>
    <p><b>Hostname:</b> $HOSTNAME</p>
    <p><b>Instance ID:</b> $INSTANCE_ID</p>
    <p><b>Private IP:</b> $PRIVATE_IP</p>
    <p><b>Availability Zone:</b> $AZ</p>
    <p><b>Region:</b> $REGION</p>
</body>
</html>
EOF