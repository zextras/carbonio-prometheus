#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required see https://prometheus.io/download/'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

# create user
useradd --no-create-home --shell /bin/false $USER 
mkdir $CONFIGDIR
defaultOptions="/etc/default/prometheus-mysql_exporter"
if [[ ! -e $defaultOptions ]]; then
	touch $defaultOptions
fi

downloadUrl=$1
wget $downloadUrl
fileName="${downloadUrl##*/}"


tar -xvzf $fileName
dirName=$(tar -tzf $fileName | head -1 | cut -f1 -d"/")
cd $dirName

# copy binaries
cp mysqld_exporter /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/mysqld_exporter

#Set defaults
echo "ARGS='--config.my-cnf $CONFIGDIR/mysqld_exporter.cnf'" > $defaultOptions

# setup systemd
echo "[Unit]
Description=Mysql Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=/usr/local/bin/mysqld_exporter \$ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/mysqld_exporter.service

systemctl daemon-reload
systemctl enable mysqld_exporter
systemctl start mysqld_exporter

echo "Setup complete.
Edit $CONFIGDIR/mysqld_exporter.cnf
Add the following rows in prometheus.yml:

- job_name: mysql_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9104']
restart:  prometheus "

