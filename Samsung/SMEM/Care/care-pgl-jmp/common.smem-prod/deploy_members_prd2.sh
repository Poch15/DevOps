#!/bin/bash

PASSWD=zjajs2020!2
REPOSITORY_PASSWD=zjajs2015!2
SSH_REPOSITORY_USER=common
SSH_USER=common.smem-prod
JAR_DIR=v2-jar
DST_DIR=/home/common/docker
DISCOVERY=("30.0.151.77" "30.0.152.77")
PROXY=("30.0.151.31" "30.0.152.31")
API1=("30.0.151.30" "30.0.152.30" "30.0.151.40" "30.0.152.40"  ) 
API2=("30.0.151.32" "30.0.152.32" )
MYPRODUCT=("30.0.151.33" "30.0.152.33" )
GATEWAY=("30.0.151.70" "30.0.152.70" )
BATCH=("30.0.151.72" )
BATCH2=("30.0.152.72" )
ADMIN=("30.0.151.10" )
REPOSITORY=("30.0.51.91")

for SERVER in "${DISCOVERY[@]}"; do
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/config-server* ${SSH_USER}@${SERVER}:$DST_DIR
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/discovery-server* ${SSH_USER}@${SERVER}:$DST_DIR
	#sshpass -p $PASSWD scp -P 2285 -r ${JAR_DIR}/members-v2-config ${SSH_USER}@${SERVER}:$DST_DIR
done

for SERVER in "${PROXY[@]}"; do
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/edge-server* ${SSH_USER}@${SERVER}:$DST_DIR
done

for SERVER in "${API1[@]}"; do
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-oauth2* ${SSH_USER}@${SERVER}:$DST_DIR
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-common* ${SSH_USER}@${SERVER}:$DST_DIR
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-user* ${SSH_USER}@${SERVER}:$DST_DIR
done

for SERVER in "${API2[@]}"; do
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-feedback* ${SSH_USER}@${SERVER}:$DST_DIR
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-content* ${SSH_USER}@${SERVER}:$DST_DIR
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-beta* ${SSH_USER}@${SERVER}:$DST_DIR
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-log* ${SSH_USER}@${SERVER}:$DST_DIR
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-search* ${SSH_USER}@${SERVER}:$DST_DIR
done

for SERVER in "${MYPRODUCT[@]}"; do
        sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-myproduct* ${SSH_USER}@${SERVER}:$DST_DIR
        sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-inbox* ${SSH_USER}@${SERVER}:$DST_DIR
        sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-survey* ${SSH_USER}@${SERVER}:$DST_DIR
done


for SERVER in "${GATEWAY[@]}"; do
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-external* ${SSH_USER}@${SERVER}:$DST_DIR
	# sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-migration* ${SSH_USER}@${SERVER}:$DST_DIR
done

for SERVER in "${BATCH[@]}"; do
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-batch* ${SSH_USER}@${SERVER}:$DST_DIR
done

for SERVER in "${BATCH2[@]}"; do
        sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-batch-inbox* ${SSH_USER}@${SERVER}:$DST_DIR
        sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-batch-myproduct* ${SSH_USER}@${SERVER}:$DST_DIR
done

for SERVER in "${ADMIN[@]}"; do
	sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/members-admin* ${SSH_USER}@${SERVER}:$DST_DIR
done

    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-oauth2* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-common* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-user* ${SSH_REPOSITORYUSER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-feedback* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-content* ${SSH_REPOSITORYUSER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-beta* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-log* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-search* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-external* ${SSH_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-migration* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-batch* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-myproduct* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-inbox* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-survey* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-banner* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
