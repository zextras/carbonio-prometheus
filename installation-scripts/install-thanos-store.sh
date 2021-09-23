#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Download url required'
    exit 0
fi

CONFIGDIR="/etc/prometheus"
DATADIR="/var/lib/thanos-cache/"
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
mkdir $DATADIR

# set ownership
chown -R $USER:$USER $CONFIGDIR
chown -R $USER:$USER $DATADIR

echo "ARGS='--grpc-address=0.0.0.0:10902 \
    --http-address=0.0.0.0:10903 \
    --data-dir=/var/lib/thanos-cache/ \
    --objstore.config-file /etc/prometheus/thanos-bucket.yml'
" > $defaultOptions

# setup systemd
echo "[Unit]
Description=Thanos Store
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
EnvironmentFile=/etc/default/thanos-store
ExecStart=/usr/local/bin/thanos store $ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/thanos-store.service

systemctl daemon-reload
systemctl enable thanos-store
# systemctl start thanos-store

echo "Setup complete.
Set your default in file $defaultOptions
Edit storage settings in  $CONFIGDIR/thanos-bucket.yml"

