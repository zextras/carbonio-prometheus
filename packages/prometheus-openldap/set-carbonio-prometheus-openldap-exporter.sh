#!/bin/bash

pkgname="carbonio-prometheus-mysqld-exporter"
source /opt/zextras/bin/zmshutil || exit 1
zmsetvars

echo "ldapAddr: $ldap_host:$ldap_port" > /opt/zextras/common/etc/prometheus/$pkgname.yml
echo "ldapUser: $zimbra_ldap_userdn" >> /opt/zextras/common/etc/prometheus/$pkgname.yml
echo "ldapPass: $zimbra_ldap_password"  >> /opt/zextras/common/etc/prometheus/$pkgname.yml
echo "interval: 1m" >> /opt/zextras/common/etc/prometheus/$pkgname.yml