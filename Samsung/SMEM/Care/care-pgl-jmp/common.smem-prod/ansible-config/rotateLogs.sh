#!/bin/bash
region=$5
serial=$4

if [ -z "$region" ]; then
    region='prd'
fi
export ANSIBLE_PERSISTENT_CONNECT_TIMEOUT=600;
export ANSIBLE_PERSISTENT_COMMAND_TIMEOUT=600;

/usr/local/bin/ansible-playbook -vvvv ./care-logrotate.yml -i ./inventories/${region}/ --extra-vars "ansible_ssh_pass=$2 ansible_ssh_user=$1 host_name=$3 concurrency=$4";
