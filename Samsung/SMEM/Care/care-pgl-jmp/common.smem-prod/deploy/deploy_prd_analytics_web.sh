#!/bin/bash -x

SERVER=30.0.151.10
PASSWD=zjajs2016!2

SSH_USER=common
TAR_DIR=/home/common.smem-prod/deploy/members-analytics
TAR_NAME=members-analytics-web.tar.gz
DST_DIR=/home/common/members-analytics/deploy/

sshpass -p $PASSWD scp -P 2285  ${TAR_DIR}/${TAR_NAME} ${SSH_USER}@${SERVER}:${DST_DIR}
