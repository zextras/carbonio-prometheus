#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

defaultOptions="/etc/default/prometheus-consul_exporter"
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
cp consul_exporter /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/consul_exporter

# setup systemd
echo "[Unit]
Description=Consul Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=/usr/local/bin/consul_exporter  \$ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/consul_exporter.service

systemctl daemon-reload
systemctl enable consul_exporter
systemctl start consul_exporter

echo "Setup complete.
Edit $defaultOptions
Add the following rows in prometheus.yml:

- job_name: consul_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9107']
restart:  prometheus "

