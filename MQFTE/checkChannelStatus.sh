#!/bin/bash

for QMANAGER in `/opt/mqm/bin/dspmq | awk {'print $1'} | sed s/QMNAME\(//g | sed s/\)//g`; do 

	for CHANNEL in `echo "display channel(*)" | /opt/mqm/bin/runmqsc $QMANAGER | grep CHANNEL | grep "CHLTYPE(SDR)" | grep -v SYSTEM | awk {'print $1'} | sed s/CHANNEL\(//g | sed s/\)//g`; 
	do
		VALUE=`echo "DISPLAY CHSTATUS ($CHANNEL)" | /opt/mqm/bin/runmqsc $QMANAGER | grep RUNNING | wc -l`
		echo $VALUE > /var/tmp/channelStatus_${CHANNEL}.txt
		/usr/bin/zabbix_sender  -z zabbix.credicard.com.ve -s srv-vccs-mqfteprd -k channelStatus_${CHANNEL} -o $VALUE	

	done
done
