#!/bin/bash
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi

echo -n "Insert the cluster credential password: "
CONSUL_HTTP_TOKEN="$(service-discover bootstrap-token --setup)"
export CONSUL_HTTP_TOKEN
echo ""

# Reduce secret exposure
export -n SETUP_CONSUL_TOKEN

SRC_CFG="/etc/carbonio/carbonio-prometheus-alertmanager/config-templates/alertmanager.yml"

echo "Uploading Alertmanager config to Consul KV"
consul kv put carbonio/alertmanager/config @"${SRC_CFG}"

echo "Verifying Consul KV entry"
consul kv get carbonio/alertmanager/config >/dev/null

echo "Rendering Alertmanager config from Consul KV"
consul-template -once \
  -template "/etc/zextras/service-discover/templates/alertmanager.yml.ctmpl:/etc/carbonio/carbonio-prometheus-alertmanager/alertmanager.yml"

echo "Validating Alertmanager configuration"
amtool check-config /etc/carbonio/carbonio-prometheus-alertmanager/alertmanager.yml

echo "Reloading Alertmanager"
systemctl restart carbonio-prometheus-alertmanager

export -n CONSUL_HTTP_TOKEN

echo "Alertmanager configuration updated successfully"