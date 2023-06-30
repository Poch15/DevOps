#!/bin/bash
region=$5
serial=$4

if [ -z "$region" ]; then
    region='prd'
fi
/usr/local/bin/ansible-playbook ./care-fluentbit-restart.yml -i ./inventories/${region}/ --extra-vars "ansible_ssh_pass=$2 ansible_ssh_user=$1 host_name=$3 concurrency=$4"
