#!/bin/bash

pkgname="carbonio-prometheus-mysqld-exporter"

mysql_user=$(/opt/zextras/bin/zmlocalconfig -s -m nokey zimbra_mysql_user)
mysql_password=$(/opt/zextras/bin/zmlocalconfig -s -m nokey zimbra_mysql_password)
mysql_bind_address=$(/opt/zextras/bin/zmlocalconfig -s -m nokey mysql_bind_address)
mysql_port=$(/opt/zextras/bin/zmlocalconfig -s -m nokey mysql_port)

{
  echo "[client]"
  echo "user= $mysql_user"
  echo "password= $mysql_password"
  echo "host= $mysql_bind_address"
  echo "port= $mysql_port"
} >/etc/carbonio/$pkgname/$pkgname.cnf

systemctl restart carbonio-prometheus-mysqld-exporter.service