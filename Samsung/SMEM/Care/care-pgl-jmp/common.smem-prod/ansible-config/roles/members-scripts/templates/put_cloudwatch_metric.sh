#!/bin/bash
# put cloudwatch metric data of the docker containers
# NameSpace: Docker
# Dimentions: HostId, ContainerName
# MetricName: CPUUtilization, MemoryUtilization, MemoryUsage

get_time_stamp() {
        time_stamp=$(date -u +%Y-%m-%dT%R:%S.000Z)
        echo "$time_stamp"
}

get_instance_id() {
        instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
        echo $instance_id
}

get_instance_name() {
        instance_id=$1

        instance_name=$(aws ec2 describe-tags --filters Name=resource-id,Values=$instance_id Name=key,Values=Name --query Tags[].Value --output text)
        echo $instance_name
}

get_docker_name() {
        docker_id=$1

        docker_name=$(docker ps -a | awk -v id="$docker_id" '$0 ~ id{print $NF}')
        echo $docker_name
}

put_metrics() {
        time_stamp=$(get_time_stamp)
        instance_id=$(get_instance_id)
        instance_name=$(get_instance_name $instance_id)
        if [ -z $instance_name ]; then
                instance_name=$instance_id
                if [ -z $instance_id ]; then
                        exit 1
                fi
        fi

        # read stats of the running containers into the array
        readarray docker_stats < <(docker stats --no-stream | sed '1d' | awk '{print $1, "\t", $2, "\t", $3, "\t", $6, "\t", $8}')

        for docker_stat in "${docker_stats[@]}"; do
                echo "$docker_stat";
                docker_id=$(echo $docker_stat | awk '{print $1}')
                cpu_usg_pct=$(echo $docker_stat | awk '{print $2}' | sed 's/%//')
                mem_usage=$(echo $docker_stat | awk '{print $3}' | sed 's/GiB//' | sed 's/MiB//')
                mem_unit=$(echo $docker_stat | awk '{print $3}' | sed 's/[0-9.]*//')
                mem_usg_pct=$(echo $docker_stat | awk '{print $4}' | sed 's/%//')
                docker_name=$(get_docker_name $docker_id)

                if [ "GiB" = "$mem_unit" ]; then
                        mem_usage=$(echo "$mem_usage*1024" | bc)
                fi
                echo "usg=$mem_usage in=$instance_name dn=$docker_name pct=$mem_usg_pct mu=$mem_unit mupct=$cpu_usg_pct did=$docker_id";
                aws cloudwatch put-metric-data --metric-name MemoryUsage --namespace Docker --value $mem_usage --unit Megabytes --dimensions InstanceName=$instance_name,ContainerName=$docker_name,instance_id=$instance_id --timestamp $time_stamp
                aws cloudwatch put-metric-data --metric-name CPUUtilization --namespace Docker --value $cpu_usg_pct --unit Percent --dimensions InstanceName=$instance_name,ContainerName=$docker_name,instance_id=$instance_id --timestamp $time_stamp
                aws cloudwatch put-metric-data --metric-name MemoryUtilization --namespace Docker --value $mem_usg_pct --unit Percent --dimensions InstanceName=$instance_name,ContainerName=$docker_name,instance_id=$instance_id --timestamp $time_stamp
        done
}

put_metrics