#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required see https://github.com/kumina/postfix_exporter/releases'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"

defaultOptions="/etc/default/prometheus-postfix_exporter"
if [[ ! -e $defaultOptions ]]; then
	touch $defaultOptions
fi

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
cp postfix_exporter /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/postfix_exporter
chmod +x /usr/local/bin/postfix_exporter

# setup systemd
echo "[Unit]
Description=Postfix Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Environment=SSL_VERIFY=false
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=/usr/local/bin/postfix_exporter \$ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/postfix_exporter.service

systemctl daemon-reload
systemctl enable postfix_exporter
systemctl start postfix_exporter

echo "Setup complete.
Edit $defaultOptions
Add the following rows in prometheus.yml:

- job_name: postfix_$(hostname -f)
  static_configs:
    - targets: ['$(hostname -f):9154']
restart:  prometheus "

