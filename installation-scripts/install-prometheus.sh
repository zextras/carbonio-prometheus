#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
DATADIR="/var/lib/prometheus/data"
USER="prometheus"
defaultOptions="/etc/default/prometheus"
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
\cp prometheus /usr/local/bin/
\cp promtool /usr/local/bin/


# create directories
mkdir $CONFIGDIR
mkdir -p $DATADIR

# Copy sample config file

if [[ -f "$CONFIGDIR/prometheus.yml" ]]; then
    echo "Config $FILE already exists."
	cp prometheus.yml $CONFIGDIR/prometheus.yml_new
else
	cp prometheus.yml $CONFIGDIR	
fi

#Copy console files
cp -r consoles $CONFIGDIR
cp -r console_libraries $CONFIGDIR

# set ownership
chown -R $USER:$USER $CONFIGDIR
chown -R $USER:$USER $DATADIR
chown $USER:$USER /usr/local/bin/prometheus
chown $USER:$USER /usr/local/bin/promtool

if [[ -f "$defaultOptions" ]]; then
    echo "Defaults $FILE already exists."
else
	echo "ARGS='--config.file /etc/prometheus/prometheus.yml \
		--storage.tsdb.retention.time=180d \
		--storage.tsdb.path /var/lib/prometheus/ \
		--web.enable-lifecycle \
		--web.enable-admin-api \
		--log.level=info \
		--storage.tsdb.max-block-duration=2h \
		--storage.tsdb.min-block-duration=2h \
		--web.console.templates=/etc/prometheus/consoles \
		--web.console.libraries=/etc/prometheus/console_libraries'
	" > $defaultOptions
fi	

# To work with thanos
#  --storage.tsdb.max-block-duration=2h \
#  --storage.tsdb.min-block-duration=2h \
# To allow reload config without restart service
# curl -X POST http://localhost:9090/-/reload
#  --web.enable-lifecycle

# setup systemd
if [[ -f "/etc/systemd/system/prometheus.service" ]]; then
    echo "Systemd already exists."
	systemctl start prometheus
else
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
	LimitNOFILE=65535

	[Install]
	WantedBy=multi-user.target" > /etc/systemd/system/prometheus.service
	systemctl daemon-reload
	systemctl enable prometheus
	systemctl start prometheus
	echo "Setup complete.
	Set your default in file $defaultOptions
	Edit you settings in  $CONFIGDIR/prometheus.yml"
fi





