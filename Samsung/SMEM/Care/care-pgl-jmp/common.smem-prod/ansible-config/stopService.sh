#!/bin/bash
MODULE=$3
region=$5
if [ -z "$region" ]; then
    region='prd'
fi
echo "build module $region"
echo $MODULE
echo "============="
ARGS=(${MODULE//,/ })
for module_name in "${ARGS[@]}";do
    /usr/local/bin/ansible-playbook ./care-stop-service.yml -i ./inventories/${region}/ --extra-vars "ansible_ssh_pass=$2 ansible_ssh_user=$1 service_name=$module_name host_name=$4";
done