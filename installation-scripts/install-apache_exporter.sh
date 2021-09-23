#!/bin/bash

# if [[ $# -eq 0 ]] ; then
    # echo 'Download url required'
    # exit 0
# fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

# create user
useradd --no-create-home --shell /bin/false $USER 

# downloadUrl=$1
# wget $downloadUrl
# fileName="${downloadUrl##*/}"


# tar -xvzf $fileName
# dirName=$(tar -tzf $fileName | head -1 | cut -f1 -d"/")
# cd $dirName

# copy binaries
cp apache_exporter /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/apache_exporter

# setup systemd
echo "[Unit]
Description=Apache Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/apache_exporter

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/apache_exporter.service

systemctl daemon-reload
systemctl enable apache_exporter
systemctl start apache_exporter

echo "Setup complete.
Add the following rows in prometheus.yml:

- job_name: node_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9117']
restart:  prometheus "

