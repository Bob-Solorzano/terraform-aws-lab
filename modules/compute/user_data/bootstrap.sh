#!/bin/bash

set -e
set -o pipefail

LOG_FILE="/var/log/bootstrap.log"

exec > >(tee -a $${LOG_FILE})
exec 2>&1

echo "Starting bootstrap..."

cat <<'HTTPD_SCRIPT' > /tmp/httpd.sh
${httpd_script}
HTTPD_SCRIPT

cat <<'CW_AGENT_SCRIPT' > /tmp/cloudwatch_agent.sh
${cloudwatch_script}
CW_AGENT_SCRIPT

chmod +x /tmp/httpd.sh
chmod +x /tmp/cloudwatch_agent.sh


echo "Installing Apache..."

if /tmp/httpd.sh; then
    echo "Apache installation completed successfully"
else
    echo "ERROR: Apache installation failed"
    exit 1
fi


echo "Installing CloudWatch Agent..."

if /tmp/cloudwatch_agent.sh; then
    echo "CloudWatch Agent installation completed successfully"
else
    echo "ERROR: CloudWatch Agent installation failed"
    exit 1
fi


echo "Bootstrap completed successfully"
exit 0