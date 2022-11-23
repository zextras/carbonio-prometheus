#!/bin/bash

pkgname="carbonio-prometheus-mysqld-exporter"
source /opt/zextras/bin/zmshutil || exit 1
zmsetvars

echo "user= $zimbra_mysql_user" >> /opt/zextras/common/etc/prometheus/$pkgname.cnf
echo "password= $zimbra_mysql_password" >> /opt/zextras/common/etc/prometheus/$pkgname.cnf
echo "host= $mysql_bind_address"  >> /opt/zextras/common/etc/prometheus/$pkgname.cnf
echo "port= $mysql_port" >> /opt/zextras/common/etc/prometheus/$pkgname.cnf