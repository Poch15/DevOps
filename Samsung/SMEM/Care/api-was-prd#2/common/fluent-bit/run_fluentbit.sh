#!/bin/bash
docker stop fluentbit;
docker rm fluentbit;
docker run -v /home/common/members-log:/log \
    --restart unless-stopped \
    -v /home/common/fluent-bit:/fluent-config \
    --name fluentbit \
    -tid bitnami/fluent-bit:1.9.3 /opt/bitnami/fluent-bit/bin/fluent-bit -c /fluent-config/fluent-bit.conf
