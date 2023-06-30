#!/bin/bash
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`;
IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`;
SERVERNAME=$(/usr/local/bin/aws ec2 describe-tags --filters Name=resource-id,Values=${INSTANCE_ID} Name=key,Values=Name --query Tags[].Value --output text);
echo "Executing LogRotation" && \
cd /home/common/members-log && \
nice -19 /usr/local/bin/aws s3 sync --exclude "*" --include "*.log.gz" . "s3://log-care/API/$SERVERNAME/$IP/" --region ap-northeast-2 && \
find . -name "*.*.lo*" -type f -mtime +2 -exec rm -rf {} \;