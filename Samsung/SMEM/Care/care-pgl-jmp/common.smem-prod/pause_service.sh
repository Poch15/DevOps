#!/bin/bash

IP=$1;

curl -X POST $IP:9130/management/pause
#curl -X POST $IP:9080/management/pause
#curl -X POST $IP:9210/management/pause

echo "${1} stopped";
