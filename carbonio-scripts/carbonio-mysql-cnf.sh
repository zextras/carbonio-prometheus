echo "[client]" > /etc/prometheus/mysqld_exporter.cnf
echo "user=zextras" >> /etc/prometheus/mysqld_exporter.cnf
/opt/zextras/bin/zmlocalconfig -s zimbra_mysql_password | awk {'print "password=" $3'} >> /etc/prometheus/mysqld_exporter.cnf
/opt/zextras/bin/zmlocalconfig -s mysql_bind_address | awk {'print "host=" $3'} >> /etc/prometheus/mysqld_exporter.cnf
/opt/zextras/bin/zmlocalconfig -s mysql_port | awk {'print "port=" $3'} >> /etc/prometheus/mysqld_exporter.cnf
