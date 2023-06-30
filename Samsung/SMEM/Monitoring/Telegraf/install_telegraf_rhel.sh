#!/bin/bash
sService='benefits';
cd /tmp/

releasever=1.20.3
basearch=amd64
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

sed -i "s/\$releasever/$(rpm -E %{rhel})/g" /etc/yum.repos.d/influxdb.repo
#Install and start the Telegraf service
yum install -y telegraf
systemctl start telegraf


#Configure Telegraf
rm -rf /etc/telegraf/telegraf.conf
cd /etc/telegraf
aws s3 sync s3://smem-base-installers/niffler/${sService}/ .

export AZ=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone)
export REGION="ap-northeast-2"
export INSTANCETYPE=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-type)
export INSTANCEID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
export SERVERNAME=$(/usr/local/bin/aws ec2 describe-tags --filters Name=resource-id,Values=$INSTANCEID Name=key,Values=Name --query Tags[].Value --output text --region $REGION)
rm /etc/telegraf/telegraf.conf;
tee -a /etc/telegraf/telegraf.conf > /dev/null << EOT
[global_tags]
  region = "${REGION}"
  availability-zone = "${AZ}"
  instance-type = "${INSTANCETYPE}"
  instance-id = "${INSTANCEID}"
  instance-name = "${SERVERNAME}"
  instanceName = "${SERVERNAME}"
  instanceType = "${INSTANCETYPE}"
  instanceId = "${INSTANCEID}"
  availabilityZone = "${AZ}"
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 5000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  omit_hostname = false
[[outputs.http]]
  url = "https://niffler.samsungsre.com:3333/v1/influx"
  timeout = "5s"
  method = "POST"
  data_format = "influx"
  content_encoding = "gzip"
  insecure_skip_verify = true
  name_prefix = "rn-"
  tls_ca = "/etc/telegraf/cert/ca.pem"
  tls_cert = "/etc/telegraf/cert/cert.pem"
  tls_key = "/etc/telegraf/cert/key.pem"
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.processes]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
  gather_services = false
  container_names = []
  source_tag = false
  container_name_include = []
  container_name_exclude = []
  timeout = "5s"
  total = false
  perdevice = true
EOT

systemctl enable telegraf
systemctl restart telegraf