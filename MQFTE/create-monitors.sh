#!/bin/bash

COMMAND="/opt/mqm/bin/fteCreateMonitor"
TASK_ROUTE="/var/mqm/task"
CONF_FILE="/usr/local/bin/monitors.conf"
COUNT=1

for i in `cat ${CONF_FILE} | grep -v \#`;do

	FILE_NAME=`echo $i | awk -F\| {'print $1'}`
	STRING_MATCH=`echo $i | awk -F\| {'print $2'}`
	AGENT=`echo $i | awk -F\| {'print $3'}`
	DIR=`echo $i | awk -F\| {'print $4'}`
	
	#echo "$COUNT -> " 
	echo "${COMMAND} -mn ${FILE_NAME} -ma ${AGENT} -md \"${DIR}\" -mt \"${TASK_ROUTE}/${FILE_NAME}.task\" -tr \"match,${STRING_MATCH}\" "
	#${COMMAND} -mn ${FILE_NAME} -ma ${AGENT} -md \"${DIR}\" -mt \"${TASK_ROUTE}/${FILE_NAME}.task\" -tr \"match,${STRING_MATCH}\" 
	#COUNT=`expr 1 + $COUNT`
	#echo;echo;echo


done
