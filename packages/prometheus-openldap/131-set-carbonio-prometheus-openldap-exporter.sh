#!/bin/bash

set -euo pipefail

pkgname="carbonio-prometheus-openldap-exporter"
default_file="/etc/default/${pkgname}"

ldap_host=$(/opt/zextras/bin/zmlocalconfig -s -m nokey ldap_host)
ldap_port=$(/opt/zextras/bin/zmlocalconfig -s -m nokey ldap_port)
ldap_userdn=$(/opt/zextras/bin/zmlocalconfig -s -m nokey zimbra_ldap_userdn)
ldap_password=$(/opt/zextras/bin/zmlocalconfig -s -m nokey zimbra_ldap_password)

cat > "${default_file}" <<EOF
PROM_ADDR=":9330"
METRICS_PATH="/metrics"
LDAP_NET="tcp"
LDAP_ADDR="${ldap_host}:${ldap_port}"
LDAP_USER="${ldap_userdn}"
LDAP_PASS="${ldap_password}"
INTERVAL="1m"
EOF

systemctl restart carbonio-prometheus-openldap-exporter.service