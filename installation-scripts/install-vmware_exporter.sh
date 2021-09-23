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
# cp vmware_exporter /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/vmware_exporter

# setup systemd
echo "[Unit]
Description=Vmware Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/vmware_exporter \
-c $CONFIGDIR/vmware_exporter.yml

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/vmware_exporter.service

systemctl daemon-reload
systemctl enable vmware_exporter
systemctl start vmware_exporter

echo "Setup complete.
Edit $CONFIGDIR/vmware_exporter.yml

Add the following rows in prometheus.yml:

- job_name: vmware_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9272']
restart:  prometheus "
