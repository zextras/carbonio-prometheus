#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Version required https://github.com/grafana/loki/releases'
    exit 0
fi

CONFIGDIR="/etc/loki"
USER="loki"

# create user
useradd --no-create-home --shell /bin/false $USER 
mkdir $CONFIGDIR
defaultOptions="/etc/default/loki"
if [[ ! -e $defaultOptions ]]; then
	touch $defaultOptions
fi


downloadUrl=https://github.com/grafana/loki/releases/download/v$1/loki-linux-amd64.zip
wget $downloadUrl
fileName="${downloadUrl##*/}"
unzip $fileName

# setup systemd
if [[ -f "/etc/systemd/system/loki.service" ]]; then
    echo "Systemd already exists."
	systemctl stop loki
	# copy binaries
	cp loki-linux-amd64 /usr/local/bin/loki
	# set ownership
	chown $USER:$USER /usr/local/bin/loki
	chown $USER:$USER /var/lib/loki
	systemctl daemon-reload
	systemctl start loki
else
	#Create db folder
	mkdir /var/lib/loki

	# copy binaries
	cp loki-linux-amd64 /usr/local/bin/loki
	
	echo "ARGS='-config.file=/etc/loki/loki-config.yml'" > $defaultOptions

	# setup systemd
	echo "[Unit]
	Description=Loki log concentrator
	Wants=network-online.target
	After=network-online.target

	[Service]
	User=$USER
	Group=$USER
	Type=simple
	EnvironmentFile=$defaultOptions
	ExecStart=/usr/local/bin/loki \$ARGS

	[Install]
	WantedBy=multi-user.target" > /etc/systemd/system/loki.service

	# set ownership
	chown $USER:$USER /usr/local/bin/loki
	chown $USER:$USER /var/lib/loki

	systemctl daemon-reload
	systemctl enable loki
	systemctl start loki

	echo "Setup complete.
	Edit the config file:
	/etc/loki/loki-config.yml"
fi


downloadUrl=https://github.com/grafana/loki/releases/download/v$1/logcli-linux-amd64.zip
wget $downloadUrl
fileName="${downloadUrl##*/}"
unzip $fileName
# copy binaries
cp logcli-linux-amd64 /usr/local/bin/logcli
