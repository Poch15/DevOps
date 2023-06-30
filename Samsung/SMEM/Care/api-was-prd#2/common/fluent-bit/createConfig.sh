#!/bin/bash
INSTANCE_ID=$(wget -qO- http://instance-data/latest/meta-data/instance-id)

rm -rf /home/common/fluent-bit/fluent-bit.conf;

tee -a /home/common/fluent-bit/fluent-bit.conf > /dev/null << EOT
[SERVICE]
    Flush 1

[INPUT]
    Name tail
    Path /log/*/*/*.log
    Exclude_Path *.gz
    Path_Key filename
    Read_from_Head False
    Tag raw.log
    Buffer_Chunk_Size   1MB
    Buffer_Max_Size     100MB
    Static_Batch_Size 100MB 
    Mem_Buf_Limit 100MB

#[FILTER]
#    Name         modify
#    Match        parsed.*
#    Add          instanceId `wget -qO- http://instance-data/latest/meta-data/instance-id`

[FILTER]
    Name rewrite_tag
    Match raw.log
    Rule \$filename \/log\/([a-z0-9A-Z\-]+)\/([a-z0-9A-Z\-]+)\/([a-z0-9A-Z\-]+).log processed.\$1.\$2.$INSTANCE_ID false
#    # Rule \$filename \/log\/([a-z\-]+)\/([a-z]+)\/([a-z]+).log processed.\$1.\$2.$INSTANCE_ID false
    Emitter_Name log_emitter
    Emitter_Mem_Buf_Limit 200M

#[OUTPUT]
#    Name stdout
#    Match *

[OUTPUT]
    Name         forward
    Host         fluentd.memberscare.internal
    Compress     gzip
    Port         24224
    Match        processed.*
EOT
