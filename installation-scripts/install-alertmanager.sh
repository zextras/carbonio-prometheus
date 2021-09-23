#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
DATADIR="/var/lib/alertmanager/data"
USER="prometheus"
defaultOptions="/etc/default/prometheus-alertmanager"

# create user
useradd --no-create-home --shell /bin/false $USER 

downloadUrl=$1
wget $downloadUrl
fileName="${downloadUrl##*/}"

tar -xvzf $fileName
dirName=$(tar -tzf $fileName | head -1 | cut -f1 -d"/")
cd $dirName

# copy binaries
cp alertmanager /usr/local/bin/
cp amtool /usr/local/bin/

# create directories
mkdir $CONFIGDIR
mkdir $CONFIGDIR/template
mkdir -p $DATADIR

# set ownership
chown -R $USER:$USER $CONFIGDIR
chown -R $USER:$USER $DATADIR
chown $USER:$USER /usr/local/bin/alertmanager
chown $USER:$USER /usr/local/bin/amtool

# Copy sample config file
if [[ -f "$CONFIGDIR/alertmanager.yml" ]]; then
    echo "Config $FILE already exists."
	cp alertmanager.yml $CONFIGDIR/alertmanager.yml_new
else
	cp alertmanager.yml $CONFIGDIR	
fi

if [[ -f "$defaultOptions" ]]; then
    echo "Defaults $FILE already exists."
else
	echo "ARGS='--config.file $CONFIGDIR/alertmanager.yml \
		--storage.path /var/lib/alertmanager/data'" > $defaultOptions
fi	

# setup systemd
echo "[Unit]
Description=Prometheus Alertmanager Service
Wants=network-online.target
After=network.target

[Service]
User=$USER
Group=$USER
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=/usr/local/bin/alertmanager \$ARGS
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/prometheus-alertmanager.service

systemctl daemon-reload
systemctl enable prometheus-alertmanager
# systemctl start prometheus-alertmanager

echo "Setup complete.
Edit $defaultOptions
Edit you settings in  $CONFIGDIR/alertmanager.yml:
Add the following rows in /etc/prometheus/prometheus.yml:

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - localhost:9093
restart both services: alertmanager and prometheus "

