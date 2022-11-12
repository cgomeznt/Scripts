#!/bin/bash

COMMAND="/opt/mqm/bin/fteCreateTemplate"
TASK_ROUTE="/var/mqm/task"
COUNT=1
CONF_FILE="/usr/local/bin/monitors.conf"

for FILE in `cat ${CONF_FILE} | grep -v \# | awk -F\| {'print $1'}`;do

	#echo "-> $FILE"

	#Destination Qmanager
	DEST_QMGR=`cat ${TASK_ROUTE}/${FILE}.task | grep destinationAgent | awk {'print $2'} | awk -F\= {'print $2'} | sed s/\"//g`

	#Destination Agent
	DEST_AGN=`cat ${TASK_ROUTE}/${FILE}.task | grep destinationAgent | awk {'print $3'} | awk -F\= {'print $2'} | tr -d '"/>'`

	#source Qmanager
	SRC_QMGR=`cat ${TASK_ROUTE}/${FILE}.task | grep sourceAgent | awk {'print $2'} | awk -F\= {'print $2'} | tr -d '"/>'`

	#Source Agent
	SRC_AGN=`cat ${TASK_ROUTE}/${FILE}.task | grep sourceAgent | awk {'print $3'} | awk -F\= {'print $2'} | tr -d '"/>'`

	#origen
	SRC=`cat ${TASK_ROUTE}/${FILE}.task | grep "<file>" | head -1 | sed s/\<\\file\>//g | awk -F\< {'print $1'} | tr -d " "`

	#destino
	DEST=`cat ${TASK_ROUTE}/${FILE}.task | grep "<file>" | tail -1 | sed s/\<\\file\>//g | awk -F\< {'print $1'} | tr -d " "`

	echo "$COMMAND -tn $FILE -sa $SRC_AGN -sm $SRC_QMGR -da $DEST_AGN -dm $DEST_QMGR -de overwrite -sd delete -dd \"$DEST\" \"$SRC\""


	COUNT=`expr 1 + $COUNT`

done
echo "Total $COUNT"
