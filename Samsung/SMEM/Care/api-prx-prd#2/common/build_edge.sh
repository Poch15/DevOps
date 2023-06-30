#!/bin/bash
module_name=edge-server
java_port=8080
EUREKA_CONFIG="-Deureka.client.service-url.defaultZone=http://discovery.memberscare.internal:8761/eureka/"

docker stop $module_name
docker rm $module_name

sed -ir 's/obj_name.*$/obj_name=edge-server/' ~/docker/scouter/agent.host/conf/java_agent.conf

cd docker 
docker build --tag $module_name --build-arg JARNAME=$module_name"-2.0.0-SNAPSHOT.jar" .
#if [ $1 = "test" ]
#elif[ $1 = "default" ]
docker run \
    --log-opt max-size=10m \
    --log-opt max-file=2 -d -p $java_port:$java_port \
    -v /home/common/docker/scouter:/scouter \
    -v /home/common/members-log/$module_name:/members-log --net="host" --name $module_name $module_name:latest java -jar -Dspring.profiles.active=default $EUREKA_CONFIG -javaagent:/scouter/agent.java/scouter.agent.jar -Dscouter.config=/scouter/agent.host/conf/java_agent.conf /jar-image/$module_name-2.0.0-SNAPSHOT.jar
#fi
