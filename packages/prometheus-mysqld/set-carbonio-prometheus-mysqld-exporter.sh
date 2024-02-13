#!/bin/bash

pkgname="carbonio-prometheus-mysqld-exporter"
#mkdir -p /etc/carbonio/carbonio-prometheus-mysqld-exporter/

# shellcheck source=/dev/null
# source /opt/zextras/bin/zmshutil || exit 1
# zmsetvars
zimbra_mysql_user=$(/opt/zextras/bin/zmlocalconfig -s -m nokey zimbra_mysql_user)
zimbra_mysql_password=$(/opt/zextras/bin/zmlocalconfig -s -m nokey zimbra_mysql_password)
mysql_bind_address=$(/opt/zextras/bin/zmlocalconfig -s -m nokey mysql_bind_address)
mysql_port=$(/opt/zextras/bin/zmlocalconfig -s -m nokey mysql_port)

{
  echo "[client]"
  echo "user= $zimbra_mysql_user"
  echo "password= $zimbra_mysql_password"
  echo "host= $mysql_bind_address"
  echo "port= $mysql_port"
} >/etc/carbonio/$pkgname/$pkgname.cnf
