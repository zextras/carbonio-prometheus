#!/bin/bash
if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi


# Decrypt the bootstrap token, asking the password to the sys admin
# --setup check for SETUP_CONSUL_TOKEN env. variable and uses it
# to avoid re-asking for the password multiple times
echo -n "Insert the cluster credential password: "
CONSUL_HTTP_TOKEN="$(service-discover bootstrap-token --setup)"
export CONSUL_HTTP_TOKEN
EXIT_CODE="$?"
echo ""
if [[ "${EXIT_CODE}" != "0" ]]; then
  echo "cannot access to bootstrap token"
  exit 1;
fi
# Limit secret visibility as much as possible
export -n SETUP_CONSUL_TOKEN


POLICY_NAME='carbonio-prometheus-policy'
POLICY_DESCRIPTION='Carbonio Prometheus service policy for config scraping'

# Create or update policy for the specific service (this will be shared across cluster)
if ! consul acl policy create -name "${POLICY_NAME}" -description "${POLICY_DESCRIPTION}" -rules @/etc/carbonio/carbonio-prometheus/service-discover/policies.json >/dev/null 2>&1; then
    if ! consul acl policy update -no-merge -name "${POLICY_NAME}" -description "${POLICY_DESCRIPTION}" -rules @/etc/carbonio/carbonio-prometheus/service-discover/policies.json; then
      echo "Setup failed: Cannot update policy for ${POLICY_NAME}"
      exit 1
    fi
fi

if [[ ! -f "/etc/carbonio/prometheus/service-discover/token" ]]; then
    # Create the token
    consul acl token create -format json -policy-name "${POLICY_NAME}" -description "Token for carbonio-prometheus/$(hostname -A)" |
      jq -r '.SecretID' > /etc/carbonio/carbonio-prometheus/service-discover/token;
    chown carbonio-prometheus:carbonio-prometheus /etc/carbonio/carbonio-prometheus/service-discover/token
    chmod 0600 /etc/carbonio/carbonio-prometheus/service-discover/token
fi



cp /etc/carbonio/carbonio-prometheus/prometheus.yml.template /etc/carbonio/carbonio-prometheus/prometheus.yml

HTTP_TOKEN=$(cat /etc/carbonio/carbonio-prometheus/service-discover/token)
sed -i s/"{{ consultoken }}"/$HTTP_TOKEN/g /etc/carbonio/carbonio-prometheus/prometheus.yml;

domain=$(hostname -d);
sed -i s/"{{ hostsdomain }}"/$domain/g /etc/carbonio/carbonio-prometheus/prometheus.yml;

consuldom=$(hostname -d | sed s/\\\./-/g);
sed -i s/"{{ consulhostsdomain }}"/$consuldom/g /etc/carbonio/carbonio-prometheus/prometheus.yml;

echo "Restarting Carbonio Prometheus Service"
systemctl restart carbonio-prometheus

echo "Reloading Service Discover"
consul reload

export -n CONSUL_HTTP_TOKEN
