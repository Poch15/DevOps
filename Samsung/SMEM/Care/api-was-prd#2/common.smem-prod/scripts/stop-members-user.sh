#!/bin/bash
module_name="members-user"
domain_name="480586329294.dkr.ecr.ap-northeast-2.amazonaws.com"
java_port="9210"
region="ap-northeast-2"
EUREKA_CONFIG="-Deureka.client.service-url.defaultZone=http://discovery.memberscare.internal:8761/eureka/"

curl -X POST localhost:$java_port/management/pause

docker stop $module_name


