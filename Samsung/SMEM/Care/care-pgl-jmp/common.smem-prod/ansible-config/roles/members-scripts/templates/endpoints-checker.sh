#!/bin/bash

ENDPOINTS=(`curl -H "Accept: application/json" http://discovery.memberscare.internal:8761/eureka/apps | jq -r .[].application[].instance[].healthCheckUrl | tr '\n' ' '`);

echo "${ENDPOINTS}"

for i in "${ENDPOINTS[@]}":

do
    echo -e "Connecting to endpoint: $i \n";
    curl $i;
    echo -e "\n";
    sleep 4
done
