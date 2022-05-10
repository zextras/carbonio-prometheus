

Files contained in this folder help you to setup Prometheus exporters on your server.
Almost all scritp take as parameter a donwnload url, that point to the file you want to download and install.
Only the push proxy require two arguments the url and the kind of installation server or client.

Once you have installed the exporters on a Zimbra server you can create config using the following commands.


### Node exporter on mailstores
Copy csv2prom.pl parsesoap.sh prom_zmqstat in /usr/local/sbin and schedule execution

/etc/crontab

```
#Parsing mailbox.csv
* * * * * root  /usr/local/sbin/csv2prom.pl /opt/zimbra/zmstat/mailboxd.csv

#Parsing threads.csv
* * * * * root  /usr/local/sbin/csv2prom.pl /opt/zimbra/zmstat/threads.csv

#Postfix stat
* * * * * root  /usr/local/sbin/prom_zmqstat

#Parsing soap.csv
* * * * * root  /usr/local/sbin/parsesoap.sh
```

Create file /etc/default/prometheus-node_exporter and write ARGS='--collector.textfile.directory /tmp/' to allow node exporter to read and expose

### Openldap exporter config

#Create configuration for Prometheus Openldap Exporter on a Zimbra Ldap Server
/opt/zimbra/bin/zmlocalconfig ldap_host | awk {'print "ldapAddr: \"" $3 ":389\""'} > /etc/prometheus/openldap_exporter.yml
/opt/zimbra/bin/zmlocalconfig zimbra_ldap_userdn | awk {'print "ldapUser: \"" $3 "\""'} >> /etc/prometheus/openldap_exporter.yml
/opt/zimbra/bin/zmlocalconfig -s zimbra_ldap_password | awk {'print "ldapPass: \"" $3 "\""'} >> /etc/prometheus/openldap_exporter.yml
echo "interval: 1m" >> /etc/prometheus/openldap_exporter.yml

### Mysql exporter config

#Create configuration for Prometheus Mysql Exporter on a Zimbra Mailstore
echo "[client]" > /etc/prometheus/mysqld_exporter.cnf
echo "user=zimbra" >> /etc/prometheus/mysqld_exporter.cnf
/opt/zimbra/bin/zmlocalconfig -s zimbra_mysql_password | awk {'print "password=" $3'} >> /etc/prometheus/mysqld_exporter.cnf
/opt/zimbra/bin/zmlocalconfig -s mysql_bind_address | awk {'print "host=" $3'} >> /etc/prometheus/mysqld_exporter.cnf
/opt/zimbra/bin/zmlocalconfig -s mysql_port | awk {'print "port=" $3'} >> /etc/prometheus/mysqld_exporter.cnf

