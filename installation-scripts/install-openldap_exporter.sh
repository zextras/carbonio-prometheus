#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required see https://github.com/tomcz/openldap_exporter/releases'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

# create user
useradd --no-create-home --shell /bin/false $USER 
mkdir $CONFIGDIR

downloadUrl=$1
wget $downloadUrl
fileName="${downloadUrl##*/}"


# tar -xvzf $fileName
# dirName=$(tar -tzf $fileName | head -1 | cut -f1 -d"/")
# cd $dirName

# copy binaries
cp openldap_exporter-linux /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/openldap_exporter-linux

#Set Executable
chmod +x /usr/local/bin/openldap_exporter-linux

# setup systemd
echo "[Unit]
Description=Openldap Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/openldap_exporter-linux \
--config /etc/prometheus/openldap_exporter.yml

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/openldap_exporter-linux.service

systemctl daemon-reload
systemctl enable openldap_exporter-linux
systemctl start openldap_exporter-linux

echo "Setup complete.
Edit $CONFIGDIR/openldap_exporter.cnf
Add the following rows in prometheus.yml:

- job_name: openldap_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9330']
restart:  prometheus "

