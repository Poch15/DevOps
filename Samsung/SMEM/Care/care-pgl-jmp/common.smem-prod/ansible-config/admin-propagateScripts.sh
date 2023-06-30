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
    /usr/local/bin/ansible-playbook ./admin-copy-script.yml -i ./inventories/${region}/ --extra-vars "ansible_ssh_pass=$2 ansible_ssh_user=$1 serviceName=$module_name";
done