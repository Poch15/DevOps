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

    # Copying EKS CONFIG
    # Compress
    cd ~/v2-jar
    rm -rf ~/v2-jar/members-v2-config.tar.gz;
    cd ./members-v2-config;
    git init

    git add solr.yml
    git commit -m "fix"
    cd ..
    tar -cvzf ~/v2-jar/members-v2-config.tar.gz members-v2-config/
    sshpass -p $REPOSITORY_PASSWD scp -P 2285 ~/${JAR_DIR}/members-v2-config.tar.gz ${SSH_REPOSITORY_USER}@${REPOSITORY}:$EKS_DST_DIR
#    rm -rf ./members-v2-config/.git;
    cd ~
