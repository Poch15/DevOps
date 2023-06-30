#!/bin/bash
region=$3
if [ -z "$region" ]; then
    region='prd'
fi
/usr/local/bin/ansible-playbook ./care-check-host.yml -i ./inventories/${region}/ --extra-vars "ansible_ssh_pass=$2 ansible_ssh_user=$1";