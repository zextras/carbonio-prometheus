#!/bin/bash

# Are we root?
if [ `whoami` != "root" ]; then
        echo "ERROR! ${0} must be run by the root user"
        exit 1
fi

# Have we got enough parameters 
if [ $# -ne 2 ]; then
	echo "Usage: ${0} downloadUrl client|server for url see https://github.com/prometheus-community/PushProx/releases"
	exit 1
else
	toInstall="${2}"
fi


CONFIGDIR="/etc/prometheus"
USER="prometheus"

defaultOptions="/etc/default/prometheus-pushprox-$toInstall"
if [[ ! -e $defaultOptions ]]; then
	if [ $toInstall == "client" ]; then
		echo "ARGS='--proxy-url=http://pushprox:8080/'" > $defaultOptions
	fi	
fi


# create user
useradd --no-create-home --shell /bin/false $USER 
mkdir $CONFIGDIR

downloadUrl=$1
wget $downloadUrl
fileName="${downloadUrl##*/}"

tar -xvzf $fileName
dirName=$(tar -tzf $fileName | head -1 | cut -f1 -d"/")
cd $dirName

# copy binaries

if [ $toInstall == "server" ]; then
	cp pushprox-proxy /usr/local/bin/
	cmd="/usr/local/bin/pushprox-proxy"
else
	cp pushprox-client /usr/local/bin/
	cmd="/usr/local/bin/pushprox-client"
fi  

# set ownership
chown $USER:$USER $cmd

# setup systemd
echo "[Unit]
Description=Prometheus PushProx $toInstall
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
EnvironmentFile=$defaultOptions
ExecStart=$cmd \$ARGS

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/prometheus-pushprox-$toInstall.service

systemctl daemon-reload
systemctl enable prometheus-pushprox-$toInstall
systemctl start prometheus-pushprox-$toInstall

echo "Setup complete.
Edit $defaultOptions"
if [ $toInstall == "server" ]; then
	echo "
	Add the following rows in prometheus.yml:

- job_name: node
  proxy_url: http://$(hostname -f):8080/
  static_configs:
    - targets: ['ExporterFQDN:ExporterPort']  
	restart:  prometheus "
fi

