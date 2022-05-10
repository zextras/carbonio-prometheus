#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
USER="prometheus"
defaultOptions="$defaultOptions"
if [[ ! -e $defaultOptions ]]; then
	touch $defaultOptions
fi

# create user
useradd --no-create-home --shell /bin/false $USER 

downloadUrl=$1
wget $downloadUrl
fileName="${downloadUrl##*/}"

tar -xvzf $fileName
dirName=$(tar -tzf $fileName | head -1 | cut -f1 -d"/")
cd $dirName

# copy binaries
cp thanos /usr/local/bin/


# create directories
mkdir $CONFIGDIR

# Copy sample config file

if [[ -f "$CONFIGDIR/thanos.yml" ]]; then
    echo "Config $FILE already exists."
	cp thanos.yml $CONFIGDIR/thanos.yml_new
else
	cp thanos.yml $CONFIGDIR	
fi

# set ownership
chown -R $USER:$USER $CONFIGDIR

echo "ARGS='--config.file /etc/prometheus/thanos.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries'
" > $defaultOptions


# setup systemd
echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=/usr/local/bin/prometheus \$ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus
# systemctl start prometheus

echo "Setup complete.
Set your default in file $defaultOptions
Edit you settings in  $CONFIGDIR/thanos.yml"

