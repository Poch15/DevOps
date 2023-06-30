#!/bin/bash
module_name="members-common"
domain_name="480586329294.dkr.ecr.ap-northeast-2.amazonaws.com"
java_port="9010"
region="ap-northeast-2"
EUREKA_CONFIG="-Deureka.client.service-url.defaultZone=http://discovery.memberscare.internal:8761/eureka/"

curl -X POST localhost:$java_port/management/pause
curl -X POST localhost:$java_port/management/service-registry?status=DOWN --header 'Content-Type:application/json'
sleep 90
# sleep 90

docker stop $module_name


