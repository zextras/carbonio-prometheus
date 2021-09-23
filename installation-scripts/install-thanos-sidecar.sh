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

if [[ -f "$CONFIGDIR/thanos-bucket.yml" ]]; then
    echo "Config $FILE already exists."
	cp thanos-bucket.yml $CONFIGDIR/thanos-bucket.yml_new
else
	cp thanos-bucket.yml $CONFIGDIR	
fi

# set ownership
chown -R $USER:$USER $CONFIGDIR

echo "ARGS='--grpc-address=0.0.0.0:10900 \
	--http-address=0.0.0.0:10901 \
	--prometheus.url=http://localhost:9090 \
    --tsdb.path /var/lib/prometheus/ \
    --objstore.config-file /etc/prometheus/thanos-bucket.yml'
" > $defaultOptions

# setup systemd
echo "[Unit]
Description=Thanos Sidecar
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
EnvironmentFile=/etc/default/thanos-sidecar
ExecStart=/usr/local/bin/thanos sidecar $ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/thanos-sidecar.service

systemctl daemon-reload
systemctl enable thanos-sidecar
# systemctl start thanos-sidecar

echo "Setup complete.
Set your default in file $defaultOptions
Edit storage settings in  $CONFIGDIR/thanos-bucket.yml"

