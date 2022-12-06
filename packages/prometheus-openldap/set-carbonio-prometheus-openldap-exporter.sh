#!/bin/bash

pkgname="carbonio-prometheus-openldap-exporter"
source /opt/zextras/bin/zmshutil || exit 1
zmsetvars

echo "ldapAddr: $ldap_host:$ldap_port" > /etc/carbonio/${pkgname}/$pkgname.yml
echo "ldapUser: $zimbra_ldap_userdn" >> /etc/carbonio/${pkgname}/$pkgname.yml
echo "ldapPass: $zimbra_ldap_password"  >> /etc/carbonio/${pkgname}/$pkgname.yml
echo "interval: 1m" >> /etc/carbonio/${pkgname}/$pkgname.yml