#!/bin/bash

pkgname="carbonio-prometheus-openldap-exporter"
ldap_host=$(/opt/zextras/bin/zmlocalconfig -s -m nokey ldap_host)
ldap_port=$(/opt/zextras/bin/zmlocalconfig -s -m nokey ldap_port)
zimbra_ldap_userdn=$(/opt/zextras/bin/zmlocalconfig -s -m nokey zimbra_ldap_userdn)
zimbra_ldap_password=$(/opt/zextras/bin/zmlocalconfig -s -m nokey zimbra_ldap_password)

echo "ldapAddr: $ldap_host:$ldap_port" > /etc/carbonio/${pkgname}/$pkgname.yml
echo "ldapUser: $zimbra_ldap_userdn" >> /etc/carbonio/${pkgname}/$pkgname.yml
echo "ldapPass: $zimbra_ldap_password"  >> /etc/carbonio/${pkgname}/$pkgname.yml
echo "interval: 1m" >> /etc/carbonio/${pkgname}/$pkgname.yml

systemctl restart carbonio-prometheus-openldap-exporter.service
