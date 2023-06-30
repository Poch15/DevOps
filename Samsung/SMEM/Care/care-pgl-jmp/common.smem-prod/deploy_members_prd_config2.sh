#!/bin/bash -x

PASSWD=zjajs2020!2

SSH_USER=common.smem-prod
JAR_DIR=v2-jar
DST_DIR=~/docker

DISCOVERY=("30.0.151.77" "30.0.152.77")

for SERVER in "${DISCOVERY[@]}"; do
        sshpass -p $PASSWD scp -P 2285 -r ${JAR_DIR}/members-v2-config ${SSH_USER}@${SERVER}:$DST_DIR
done
