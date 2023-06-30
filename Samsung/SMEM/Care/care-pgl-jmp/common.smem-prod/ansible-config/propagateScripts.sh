#!/bin/bash

MODULE=$3
region=$4
if [ -z "$region" ]; then
    region='prd'
fi
echo "build module $region"
echo $MODULE
echo "============="
ARGS=(${MODULE//,/ })
for module_name in "${ARGS[@]}";do
    # run module for individual script
    service_name=$(echo $module_name | sed -E 's/(.*?)\-old.*/\1/')    
    /usr/local/bin/ansible-playbook ./care-copy-script.yml -i ./inventories/${region}/ --extra-vars "ansible_ssh_pass=$2 ansible_ssh_user=$1 serviceName=$service_name targetServers=$module_name";
done