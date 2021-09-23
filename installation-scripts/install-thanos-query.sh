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

echo "ARGS='--http-address=0.0.0.0:29090 \
    --grpc-address=0.0.0.0:10906 \
    --store=first_store:10902 \
    --store=second_store:10902 \
    --query.replica-label replica-label'
" > $defaultOptions

# setup systemd
echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
EnvironmentFile=/etc/default/thanos-query
ExecStart=/usr/local/bin/thanos query $ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/thanos-query.service

systemctl daemon-reload
systemctl enable thanos-query
# systemctl start prometheus

echo "Setup complete.
Set your default in file $defaultOptions
Edit storage settings in  $CONFIGDIR/thanos-bucket.yml"

