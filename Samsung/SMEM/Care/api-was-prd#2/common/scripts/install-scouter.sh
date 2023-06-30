#Scouter Installation START
IP_ADDRESS=$(curl 169.254.169.254/latest/meta-data/local-ipv4/)
INSTANCE_ID=$(curl 169.254.169.254/latest/meta-data/instance-id/)
SERVERNAME=$(/usr/local/bin/aws ec2 describe-tags --filters Name=resource-id,Values=$INSTANCE_ID Name=key,Values=Name --query Tags[].Value --output text --region ${this.getProjectSettings('region')});

# Export these so that perl will be able to use the variables
export APP_NAME="care-pgl"
export SCOUTER_COLLECTOR_IP="30.1.11.238"

cd /home/common
aws s3 cp s3://smem-base-installers/Scouter/installScouterAgent.sh .
chmod 744 /home/common/installScouterAgent.sh
bash -x /home/common/installScouterAgent.sh "$IP_ADDRESS" "$INSTANCE_ID" "$SERVERNAME" "$APP_NAME" "$SCOUTER_COLLECTOR_IP"
