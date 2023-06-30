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
REPOSITORY=("30.0.151.91")

    # Copying EKS CONFIG
    # Compress
    cd /home/common.smem-prod/jenkins/workspace/care-ansible-script-sync
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
