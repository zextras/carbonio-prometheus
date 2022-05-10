now=$(date +"%H:%M")
sleep 10
metrics=$(grep $now /opt/zextras/zmstat/soap.csv | awk -F ',' '{print "soap_exec_count {request=\"" $2 "\"} " $3 "\nsoap_exec_ms_avg {request=\"" $2 "\"} " $4}')
# echo "$now $metrics"
if [ -n "$metrics" ];
then
# echo "Found $now $metrics"    
 echo "# $now" > /tmp/soap.prom
 grep $now /opt/zextras/zmstat/soap.csv | awk -F ',' '{print "soap_exec_count {request=\"" $2 "\"} " $3 "\nsoap_exec_ms_avg {request=\"" $2 "\"} " $4}' >> /tmp/soap.prom
 exit 0
fi
sleep 15
metrics=$(grep $now /opt/zextras/zmstat/soap.csv | awk -F ',' '{print "soap_exec_count {request=\"" $2 "\"} " $3 "\nsoap_exec_ms_avg {request=\"" $2 "\"} " $4}')
# echo "$now $metrics"
if [ -n "$metrics" ];
then
# echo "Found $now $metrics"    
 echo "# $now" > /tmp/soap.prom
 grep $now /opt/zextras/zmstat/soap.csv | awk -F ',' '{print "soap_exec_count {request=\"" $2 "\"} " $3 "\nsoap_exec_ms_avg {request=\"" $2 "\"} " $4}' >> /tmp/soap.prom
 exit 0
fi
sleep 15
metrics=$(grep $now /opt/zextras/zmstat/soap.csv | awk -F ',' '{print "soap_exec_count {request=\"" $2 "\"} " $3 "\nsoap_exec_ms_avg {request=\"" $2 "\"} " $4}')
# echo "$now $metrics"
if [ -n "$metrics" ];
then
# echo "Found $now $metrics"    
 echo "# $now" > /tmp/soap.prom
 grep $now /opt/zextras/zmstat/soap.csv | awk -F ',' '{print "soap_exec_count {request=\"" $2 "\"} " $3 "\nsoap_exec_ms_avg {request=\"" $2 "\"} " $4}' >> /tmp/soap.prom
 exit 0
fi
sleep 15
metrics=$(grep $now /opt/zextras/zmstat/soap.csv | awk -F ',' '{print "soap_exec_count {request=\"" $2 "\"} " $3 "\nsoap_exec_ms_avg {request=\"" $2 "\"} " $4}')
# echo "$now $metrics"
if [ -n "$metrics" ];
then
# echo "Found $now $metrics"    
 echo "# $now" > /tmp/soap.prom
 grep $now /opt/zextras
/zmstat/soap.csv | awk -F ',' '{print "soap_exec_count {request=\"" $2 "\"} " $3 "\nsoap_exec_ms_avg {request=\"" $2 "\"} " $4}' >> /tmp/soap.prom
 exit 0
fi

