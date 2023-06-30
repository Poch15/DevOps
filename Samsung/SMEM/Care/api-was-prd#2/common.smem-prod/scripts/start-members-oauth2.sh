#!/bin/bash
module_name="members-oauth2"
domain_name="480586329294.dkr.ecr.ap-northeast-2.amazonaws.com"
java_port="9080"
region="ap-northeast-2"
EUREKA_CONFIG="-Deureka.client.service-url.defaultZone=http://discovery.memberscare.internal:8761/eureka/"

curl -X POST localhost:$java_port/management/pause
curl -X POST localhost:$java_port/management/service-registry?status=DOWN --header 'Content-Type:application/json'
sleep 90
# sleep 90

docker stop $module_name
docker rm $module_name

docker rmi $domain_name/$module_name

if [ "$region" != "cn-northwest-1" ];then
    #/home/common/scripts/login.exp
    $(aws ecr get-login --no-include-email --region ap-northeast-2);
fi

# cd docker
docker pull $domain_name/$module_name


# For sentry
# Until sentry 1.9.27 will be available, 
alburl='internal-care-pgl-sentry-internal-lb-614688836.ap-northeast-2.elb.amazonaws.com';
# 
docker run --log-opt max-size=10m --log-opt max-file=2 -d \
    -v /home/common/members-log/$module_name:/members-log -v /home/common/docker/scouter:/scouter \
    --net="host" --name $module_name $domain_name/$module_name:latest \
    java -jar -Dspring.profiles.active=default $EUREKA_CONFIG -javaagent:/scouter/agent.java/scouter.agent.jar \
    -Dscouter.config=/scouter/agent.host/conf/java_agent_$module_name.conf /jar-image/$module_name-2.0.0-SNAPSHOT.jar

# this is not necessary because we already have a checker
# sleep 90
