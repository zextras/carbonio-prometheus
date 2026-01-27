#!/bin/bash
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi

echo -n "Insert the cluster credential password: "
CONSUL_HTTP_TOKEN="$(service-discover bootstrap-token --setup)"
export CONSUL_HTTP_TOKEN
EXIT_CODE="$?"
echo ""

if [[ ${EXIT_CODE} != "0" ]]; then
  echo "Cannot access bootstrap token"
  exit 1
fi

# Reduce secret exposure
export -n SETUP_CONSUL_TOKEN

POLICY_NAME="carbonio-alertmanager-policy"
POLICY_DESCRIPTION="Carbonio Alertmanager policy for KV config access"
POLICY_FILE="/etc/carbonio/carbonio-prometheus-alertmanager/service-discover/policies.json"

if ! consul acl policy create \
  -name "${POLICY_NAME}" \
  -description "${POLICY_DESCRIPTION}" \
  -rules @"${POLICY_FILE}" >/dev/null 2>&1; then

  if ! consul acl policy update \
    -no-merge \
    -name "${POLICY_NAME}" \
    -description "${POLICY_DESCRIPTION}" \
    -rules @"${POLICY_FILE}"; then
    echo "Setup failed: cannot update policy ${POLICY_NAME}"
    exit 1
  fi
fi

TOKEN_DIR="/etc/carbonio/carbonio-prometheus-alertmanager/service-discover"
TOKEN_FILE="${TOKEN_DIR}/token"

mkdir -p "${TOKEN_DIR}"

if [[ ! -f "${TOKEN_FILE}" ]]; then
  consul acl token create \
    -format json \
    -policy-name "${POLICY_NAME}" \
    -description "Token for carbonio-alertmanager/$(hostname -A)" |
    jq -r '.SecretID' >"${TOKEN_FILE}"

  chown carbonio-prometheus:carbonio-prometheus "${TOKEN_FILE}"
  chmod 0600 "${TOKEN_FILE}"
fi

# Upload Alertmanager config to Consul KV
TMP_CFG="/etc/carbonio/carbonio-prometheus-alertmanager/config-templates/alertmanager.yml"

echo "Uploading Alertmanager config to Consul KV"
consul kv put carbonio/alertmanager/config @"${TMP_CFG}"

echo "Verifying Consul KV entry"
consul kv get carbonio/alertmanager/config >/dev/null

consul reload 

rm -f "${TMP_CFG}"
export -n CONSUL_HTTP_TOKEN

echo "Alertmanager configuration successfully stored in Consul KV"