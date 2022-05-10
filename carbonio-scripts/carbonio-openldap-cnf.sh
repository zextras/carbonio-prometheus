/opt/zextras/bin/zmlocalconfig ldap_host | awk {'print "ldapAddr: \"" $3 ":389\""'} > /etc/prometheus/openldap_exporter.yml
/opt/zextras/bin/zmlocalconfig zimbra_ldap_userdn | awk {'print "ldapUser: \"" $3 "\""'} >> /etc/prometheus/openldap_exporter.yml
/opt/zextras/bin/zmlocalconfig -s zimbra_ldap_password | awk {'print "ldapPass: \"" $3 "\""'} >> /etc/prometheus/openldap_exporter.yml
echo "interval: 1m" >> /etc/prometheus/openldap_exporter.yml


