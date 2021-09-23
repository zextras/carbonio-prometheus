#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

# create user
useradd --no-create-home --shell /bin/false $USER 

downloadUrl=$1
wget $downloadUrl
fileName="${downloadUrl##*/}"

tar -xvzf $fileName
dirName=$(tar -tzf $fileName | head -1 | cut -f1 -d"/")
cd $dirName

# copy binaries
cp pushgateway /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/pushgateway

# setup systemd
echo "[Unit]
Description=Prometheus Push Gateway
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/pushgateway \
    --log.level=\"info\" \
    --log.format=\"logger:stdout?json=true\"

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/pushgateway.service

systemctl daemon-reload
systemctl enable pushgateway
systemctl start pushgateway

echo "Setup complete.
Add the following rows in /etc/prometheus/prometheus.yml:
- job_name: pushgateway
  honor_labels: true
  static_configs:
   - targets: ['localhost:9091']
restart prometheus "

