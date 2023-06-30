#!/bin/bash

IP=$1;

echo "members-feedback"
curl -X POST $IP:9110/management/pause
echo "members-beta"
curl -X POST $IP:9910/management/pause
echo "members-content"
curl -X POST $IP:9112/management/service-registry?status=DOWN --header 'Content-Type:application/json'
echo "members-log"
curl -X POST $IP:9920/management/pause
echo "members-search"
curl -X POST $IP:9120/management/pause
curl -X POST $IP:9120/management/service-registry?status=DOWN --header 'Content-Type:application/json'

echo "${1} stopped";
