#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required see https://github.com/prometheus/blackbox_exporter/releases'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

defaultOptions="/etc/default/prometheus-blackbox_exporter"
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
cp blackbox_exporter /usr/local/bin/

# copy config
cp blackbox.yml $CONFIGDIR

# set ownership
chown $USER:$USER /usr/local/bin/blackbox_exporter

# setup systemd
echo "[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=/usr/local/bin/blackbox_exporter  \$ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/blackbox_exporter.service

systemctl daemon-reload
systemctl enable blackbox_exporter
systemctl start blackbox_exporter

echo "Setup complete.
Edit $defaultOptions
Add the following rows in prometheus.yml:

- job_name: blackbox_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9115']
restart:  prometheus "

