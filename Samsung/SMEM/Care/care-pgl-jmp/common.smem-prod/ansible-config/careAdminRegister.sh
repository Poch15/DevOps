#!/bin/bash
REQUESTOR=$3
if [ -z "$region" ]; then
    region='prd'
fi
echo "build module $region"
echo "Registering request from $REQUESTOR"
echo "============="
ARGS=(${REQUESTOR//,/ })
for request in "${ARGS[@]}";do
    /usr/local/bin/ansible-playbook ./care-admin-register.yml -i ./inventories/${region}/ --extra-vars "ansible_ssh_pass=$2 ansible_ssh_user=$1 requestor=$request ip_address=$4 ip_type=$5 host_name=$6 ansible_sudo_pass=$2";
done