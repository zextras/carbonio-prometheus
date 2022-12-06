#!/bin/bash

pkgname="carbonio-prometheus-mysqld-exporter"
source /opt/zextras/bin/zmshutil || exit 1
zmsetvars

echo "user= $zimbra_mysql_user" >> /etc/carbonio/$pkgname/$pkgname.cnf
echo "password= $zimbra_mysql_password" >> /etc/carbonio/$pkgname/$pkgname.cnf
echo "host= $mysql_bind_address"  >> /etc/carbonio/$pkgname/$pkgname.cnf
echo "port= $mysql_port" >> /etc/carbonio/$pkgname/$pkgname.cnf