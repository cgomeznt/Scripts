#!/bin/bash

cat /usr/local/bin/agents.lst | grep -v "#" | awk -F\: {'print $1"|"$4"|"$3'} > /var/tmp/fteListAgents.txt

#egrep 'READY|ACTIVE'
for i in `cat /var/tmp/fteListAgents.txt`; do
	
	QMANAGER=`echo $i | awk -F\| {'print $1'}`
	AGENT=`echo $i | awk -F\| {'print $2'}`
	PORT=`echo $i | awk -F\| {'print $3'}`
	
	/opt/mqm/bin/ftePingAgent -w 15 -m $QMANAGER $AGENT
	#COUNT=`netstat -tan | grep $PORT | awk {'print $5 " " $6'} | grep  -v 10.136.0. | grep ESTABLISHED | wc -l`
	COUNT=`netstat -tan | grep $PORT | awk {'print $5 " " $6'} | grep -v 10.136.0. | grep -v 10.140.0. | grep ESTABLISHED | wc -l`

	if [ $COUNT -gt 0  ];then
		VALUE=1
	else
		VALUE=0	
	fi	
	echo Value es: $AGENT:$VALUE
	echo $VALUE >  /var/tmp/fteAgentStatus_${QMANAGER}.txt
	echo "Enviando a zabbix"
	/usr/bin/zabbix_sender  -z zabbix.credicard.com.ve -s srv-vccs-mqfteprd -k fteAgentStatus_${QMANAGER} -o $VALUE
	sleep 1
done

rm -f /var/tmp/fteListAgents.txt

	
