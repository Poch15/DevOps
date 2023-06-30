#!/bin/bash

cd /tmp/
aws s3 cp s3://smem-base-installers/telegraf/telegraf_${version}-1_${arch}.deb .
dpkg -i telegraf_${version}-1_${arch}.deb

#Install and start the Telegraf service
apt-get install -y telegraf
systemctl start telegraf

#Configure Telegraf

rm -rf /etc/telegraf/telegraf.conf
cd /etc/telegraf
aws s3 sync s3://smem-base-installers/niffler/${sService}/ .
chmod 744 /etc/telegraf/envs.sh
bash /etc/telegraf/envs.sh

#Restart Telegraf service
systemctl restart telegraf
