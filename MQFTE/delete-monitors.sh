#!/bin/bash

COMMAND="/opt/mqm/bin/fteDeleteMonitor"
TASK_ROUTE="/var/mqm/task"
CONF_FILE="/usr/local/bin/monitors.conf"
COUNT=1

for i in `cat ${CONF_FILE} | grep -v \#`;do

	FILE_NAME=`echo $i | awk -F\| {'print $1'}`
	AGENT=`echo $i | awk -F\| {'print $3'}`
	
	echo "$COUNT -> " 
	echo "${COMMAND} -mn ${FILE_NAME} -ma ${AGENT}"
	#${COMMAND} -mn ${FILE_NAME} -ma ${AGENT}
	COUNT=`expr 1 + $COUNT`
	echo;echo;echo


done
