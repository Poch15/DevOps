#!/bin/bash -x

SERVER=30.0.151.137
PASSWD=zjajs2020!2

SSH_USER=common.smem-prod
TAR_DIR=/home/common.smem-prod/deploy/members-analytics
TAR_NAME=members-analytics-batch.tar.gz
DST_DIR=/home/common.smem-prod/deploy/

sshpass -p $PASSWD scp -P 2285  ${TAR_DIR}/${TAR_NAME} ${SSH_USER}@${SERVER}:${DST_DIR}
