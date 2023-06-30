#!/bin/bash -x

PASSWD=zjajs2020!2

SSH_USER=common.smem-prod
JAR_DIR=v2-jar
DST_DIR=~/docker

DISCOVERY=("30.0.151.77" "30.0.152.77")

for SERVER in "${DISCOVERY[@]}"; do
    scp -P 2285 -r ${JAR_DIR}/members-v2-config ${SSH_USER}@${SERVER}:$DST_DIR
    echo "--- CHANGING PERMISSIONS ---";
    ssh -p2285 ${SSH_USER}@${SERVER} 'chmod -R 644 /home/common.smem-prod/docker/members-v2-config/*';
    echo "--- DEPLOYING NEW CONFIG---";
    ssh -p2285 ${SSH_USER}@${SERVER} 'bash -x /home/common.smem-prod/deploy_config.sh';
    #sshpass -p $PASSWD scp -P 2285 -r ${JAR_DIR}/members-v2-config ${SSH_USER}@${SERVER}:$DST_DIR
done
