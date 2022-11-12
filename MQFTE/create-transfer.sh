#!//bin/bash

COMMAND="/var/mqm/WMQFTE/bin/fteCreateTransfer"
TASK_ROUTE="/var/mqm/task"
COUNT=1
CONF_FILE="/usr/local/bin/monitors.conf"

echo `date '+%Y-%m-%d %T'` "Iniciando proceso manual de transferencia"
ps -ef | grep create-transfer | grep -v grep | grep -v tail |wc -l

if [ `ps -ef | grep create-transfer | grep -v grep | grep -v tail |wc -l` -ge 3 ];then

	echo `date '+%Y-%m-%d %T'` "Existe un proceso ejecutandose. No se ejecutara esta vez"
	exit 1
fi

for FILE in `cat ${CONF_FILE} | grep -v \# | awk -F\| {'print $1'}`;do

	#Destination Qmanager
	DEST_QMGR=`cat ${TASK_ROUTE}/${FILE}.task | grep destinationAgent | awk {'print $2'} | awk -F\= {'print $2'} | sed s/\"//g`

	#Destination Agent
	DEST_AGN=`cat ${TASK_ROUTE}/${FILE}.task | grep destinationAgent | awk {'print $3'} | awk -F\= {'print $2'} | tr -d '"/>'`

	#source Qmanager
	SRC_QMGR=`cat ${TASK_ROUTE}/${FILE}.task | grep sourceAgent | awk {'print $2'} | awk -F\= {'print $2'} | tr -d '"/>'`

	#Source Agent
	SRC_AGN=`cat ${TASK_ROUTE}/${FILE}.task | grep sourceAgent | awk {'print $3'} | awk -F\= {'print $2'} | tr -d '"/>'`

	#Control File
	CRT_FILE=`cat ${CONF_FILE} | grep $FILE\| | awk -F\| {'print $2'}`

	#origen

	SRC=`cat ${TASK_ROUTE}/${FILE}.task | grep "<file>" | head -1 | sed s/\<\\file\>//g | awk -F\< {'print $1'} | tr -d " "`

	if [ `echo "$SRC" | grep E\: | wc -l | tr -d ' '` -eq 1 ]; then

		DIR=${SRC}
		DIR=`echo ${SRC}`
		CNTROL="${DIR}${CRT_FILE}"
	
	elif [ `echo "$SRC" | grep C\: | wc -l | tr -d ' '` -eq 1 ]; then

		DIR=`echo "$SRC" | tr -d '*'`
		CNTROL=${DIR}${CRT_FILE}
	else
		DIR=`echo ${SRC} | tr -d "*" `
		CNTROL=${DIR}${CRT_FILE}

	fi

	#destino
	DEST=`cat ${TASK_ROUTE}/${FILE}.task | grep "<file>" | tail -1 | sed s/\<\\file\>//g | awk -F\< {'print $1'} | tr -d " "`

	echo  `date '+%Y-%m-%d %T'` " -> ${COUNT}"



       	echo "$COMMAND -sa $SRC_AGN -sm $SRC_QMGR -da $DEST_AGN -dm $DEST_QMGR -tr file=exist,$CNTROL -sd delete -w -dd \"$DEST\" -de overwrite \"$SRC\""
       	#$COMMAND -sa $SRC_AGN -sm $SRC_QMGR -da $DEST_AGN -dm $DEST_QMGR -tr file=exist,$CNTROL -sd delete -w -dd \"$DEST\" -de overwrite \"$SRC\"

	
	COUNT=`expr 1 + $COUNT`
	echo


done


