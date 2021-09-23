#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

defaultOptions="/etc/default/prometheus-node_exporter"
touch $defaultOptions

# create user
useradd --no-create-home --shell /bin/false $USER 

downloadUrl=$1
wget $downloadUrl
fileName="${downloadUrl##*/}"

tar -xvzf $fileName
dirName=$(tar -tzf $fileName | head -1 | cut -f1 -d"/")
cd $dirName

# copy binaries
cp node_exporter /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/node_exporter

# setup systemd
echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=/usr/local/bin/node_exporter  \$ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "Setup complete.
Edit $defaultOptions
Add the following rows in prometheus.yml:

- job_name: node_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9100']
restart:  prometheus "

