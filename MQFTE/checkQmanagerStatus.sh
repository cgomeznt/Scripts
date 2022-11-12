#!/bin/bash


for i in `/opt/mqm/bin/dspmq | awk {'print $1'} | sed s/QMNAME\(//g | sed s/\)//g`; do 
	
	VALUE=`/opt/mqm/bin/dspmq | grep $i | grep Running | wc -l`
	echo $VALUE  > /var/tmp/Qmanager_${i}_status.txt 
	/usr/bin/zabbix_sender	-z zabbix.credicard.com.ve -s srv-vccs-mqfteprd -k Qmanager_${i}_status -o $VALUE
	#sleep 1
done
