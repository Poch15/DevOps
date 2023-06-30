#!/bin/bash

PASSWD=zjajs2020!2
ADMIN_PASSWD=zjajs2016!2
REPOSITORY_PASSWD=zjajs2020!2
SSH_ADMIN_USER=common
SSH_REPOSITORY_USER=common.smem-prod
SSH_USER=common.smem-prod
JAR_DIR=v2-jar
DST_DIR=/home/common/docker
EKS_DST_DIR=~/docker-eks
REPO_DST_DIR=~/docker
DISCOVERY=("30.0.151.77" "30.0.152.77")
PROXY=("30.0.151.31" "30.0.152.31")
API1=("30.0.151.30" "30.0.152.30" "30.0.151.40" "30.0.152.40"  ) 
API2=("30.0.151.32" "30.0.152.32" )
MYPRODUCT=("30.0.151.33" "30.0.152.33" )
GATEWAY=("30.0.151.70" "30.0.152.70" )
BATCH=("30.0.151.72" )
BATCH2=("30.0.152.72" )
ADMIN=("30.0.151.10" )
REPOSITORY=("30.0.151.91")
API_PRX=("30.0.152.22" "30.0.151.22" "30.0.151.23")

for SERVER in "${API_PRX[@]}"; do
    sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/edge-server* ${SSH_ADMIN_USER}@${SERVER}:${DST_DIR}
done

for SERVER in "${DISCOVERY[@]}"; do
    sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/discovery-server* ${SSH_USER}@${SERVER}:$DST_DIR
    sshpass -p $PASSWD scp -P 2285 ${JAR_DIR}/config-server* ${SSH_USER}@${SERVER}:$DST_DIR
done

for SERVER in "${ADMIN[@]}"; do
    sshpass -p $ADMIN_PASSWD scp -P 2285 ${JAR_DIR}/members-admin* ${SSH_ADMIN_USER}@${SERVER}:$DST_DIR
done

    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-oauth2* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-common* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-user* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-feedback* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-content* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-beta* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-log* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-search* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-external* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
#    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-migration* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-batch* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-myproduct* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-inbox* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-survey* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-banner* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$REPO_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/members-benefit* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$EKS_DST_DIR
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/config-server* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$EKS_DST_DIR/members-config-server-2.0.0-SNAPSHOT.jar
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ${JAR_DIR}/discovery-server* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$EKS_DST_DIR/members-discovery-server-2.0.0-SNAPSHOT.jar

    # Copying EKS CONFIG
    # Compress
    cd ~/v2-jar
    rm -rf ~/v2-jar/members-v2-config.tar.gz;
    cd ./members-v2-config;
    cp ./metadata.config ../
    git init
    git add solr.yml
    git commit -m "fix"
    cd ..
    rm -rf ~/v2-jar/members-v2-config/metadata.config
    tar -cvzf ~/v2-jar/members-v2-config.tar.gz members-v2-config/
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ~/${JAR_DIR}/members-v2-config.tar.gz ${SSH_REPOSITORY_USER}@${REPOSITORY}:$EKS_DST_DIR
    rm -rf ./members-v2-config/.git;
    cd ~
    # Send Metadata as well
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ~/${JAR_DIR}/metadata* ${SSH_REPOSITORY_USER}@${REPOSITORY}:$EKS_DST_DIR
