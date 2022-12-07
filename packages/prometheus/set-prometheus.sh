#!/bin/bash
# Read Password
echo -n Service Discover Password: 
read -s password
export  CONSUL_HTTP_TOKEN=$(echo $password | gpg --batch --yes --passphrase-fd 0 -qdo - /etc/zextras/service-discover/cluster-credentials.tar.gpg | tar xOf - consul-acl-secret.json | jq .SecretID -r);

sed -i s/"{{ consultoken }}"/$CONSUL_HTTP_TOKEN/g /etc/carbonio/carbonio-prometheus/prometheus.yml;
dom=$(hostname -d);
sed -i s/"{{ hostsdomain }}"/$dom/g /etc/carbonio/carbonio-prometheus/prometheus.yml;
consuldom=$(echo $(hostname -d) | sed s/\\\./-/g);
sed -i s/"{{ consulhostsdomain }}"/$consuldom/g /etc/carbonio/carbonio-prometheus/prometheus.yml;

echo "Restarting Carbonio Prometheus Service"
systemctl restart carbonio-prometheus

echo "Reloading Service Discover"
consul reload