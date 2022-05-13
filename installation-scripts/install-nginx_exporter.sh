#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required see https://github.com/nginxinc/nginx-prometheus-exporter/releases'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

# create user
useradd --no-create-home --shell /bin/false $USER 
mkdir $CONFIGDIR
defaultOptions="/etc/default/prometheus-nginx_exporter"
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
cp nginx-prometheus-exporter /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/nginx-prometheus-exporter

echo "SSL_VERIFY=false
ARGS='-nginx.scrape-uri=https://localhost/nginx_status'" > $defaultOptions

# setup systemd
echo "[Unit]
Description=Nginx Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=/usr/local/bin/nginx-prometheus-exporter \$ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/nginx-prometheus-exporter.service

systemctl daemon-reload
systemctl enable nginx-prometheus-exporter
systemctl start nginx-prometheus-exporter

echo "Setup complete.
Add the following rows in prometheus.yml:

- job_name: nginx_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9113']
restart:  prometheus "

