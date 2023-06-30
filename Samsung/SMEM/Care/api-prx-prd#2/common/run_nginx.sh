#!/bin/bash

docker stop nginx;
docker rm nginx;

HOSTNAME=$(hostname)
docker run -h $HOSTNAME \
    --restart unless-stopped \
    -v /home/common/nginx:/etc/nginx/conf.d \
    -v /home/common/nginx/404.html:/usr/share/nginx/html/404.html \
    -v /home/common/nginx/403.html:/usr/share/nginx/html/403.html \
    -v /home/common/nginx-log:/var/log/nginx \
    --net host \
    --name nginx -itd nginx:1.21

