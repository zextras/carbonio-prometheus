#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required see https://github.com/grafana/promtail/releases'
    exit 0
fi

CONFIGDIR="/etc/promtail"
USER="promtail"

# create user
useradd --no-create-home --shell /bin/false $USER 
mkdir $CONFIGDIR
defaultOptions="/etc/default/promtail"
if [[ ! -e $defaultOptions ]]; then
	touch $defaultOptions
fi

downloadUrl=https://github.com/grafana/loki/releases/download/v$1/promtail-linux-amd64.zip
wget $downloadUrl
fileName="${downloadUrl##*/}"
unzip $fileName

# setup systemd
if [[ -f "/etc/systemd/system/promtail.service" ]]; then
    echo "Systemd already exists."
	systemctl stop promtail
	# copy binaries
	cp promtail-linux-amd64 /usr/local/bin/promtail
	# set ownership
	chown $USER:$USER /usr/local/bin/promtail
	systemctl daemon-reload
	systemctl start promtail
else
	# copy binaries
	cp promtail-linux-amd64 /usr/local/bin/promtail
	# set ownership
	chown $USER:$USER /usr/local/bin/promtail
	
	echo "ARGS='-config.expand-env=true --config.file=/etc/promtail/promtail.yml'" > $defaultOptions
	
	echo "[Unit]
	Description=Promtail
	Wants=network-online.target
	After=network-online.target

	[Service]
	User=$USER
	Group=$USER
	Type=simple
	EnvironmentFile=$defaultOptions
	ExecStart=/usr/local/bin/promtail \$ARGS

	[Install]
	WantedBy=multi-user.target" > /etc/systemd/system/promtail.service

	systemctl daemon-reload
	systemctl enable promtail
	systemctl start promtail

	echo "Setup complete.
	Edit the config file:
	/etc/promtail/promtail.yml"
fi
