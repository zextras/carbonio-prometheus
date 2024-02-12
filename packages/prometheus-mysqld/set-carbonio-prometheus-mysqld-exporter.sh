#!/bin/bash

pkgname="carbonio-prometheus-mysqld-exporter"
#mkdir -p /etc/carbonio/carbonio-prometheus-mysqld-exporter/

# shellcheck source=/dev/null
source /opt/zextras/bin/zmshutil || exit 1
zmsetvars

{
  echo "[client]"
  echo "user= $zimbra_mysql_user"
  echo "password= $zimbra_mysql_password"
  echo "host= $mysql_bind_address"
  echo "port= $mysql_port"
} >/etc/carbonio/$pkgname/$pkgname.cnf
