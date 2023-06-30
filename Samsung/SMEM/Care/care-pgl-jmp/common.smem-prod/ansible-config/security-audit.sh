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
    /usr/local/bin/ansible-playbook ./security-audit.yml -i ./inventories/${region}/ --extra-vars "ansible_ssh_pass=$2 ansible_ssh_user=$1 host_name=$4 ansible_sudo_pass=$2";
done