#!/bin/bash

module_name="members-logstash"
domain_name="480586329294.dkr.ecr.ap-northeast-2.amazonaws.com"

docker stop $module_name
docker rm $module_name
docker rmi $domain_name/$module_name
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $domain_name

echo "======================"
echo "Pulling image from ECR"
echo "======================"

docker pull $domain_name/$module_name

mkdir -p /home/common/logstash-data;
chown -R 1001:1001 /home/common/logstash-data;

docker run -v /home/common/members-log:/home/common/members-log \
    --restart unless-stopped \
    -v /home/common/logstash-data/:/usr/share/logstash/data:rw \
    -v /home/common/logstash/logstash.conf:/usr/share/logstash/config/conf.d/logstash.conf \
    --name $module_name \
    -tid $domain_name/$module_name:latest --path.settings /usr/share/logstash/config;
