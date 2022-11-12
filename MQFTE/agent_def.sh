#!/bin/bash

CHANNEL="SYSTEM.ADMIN.SVRCONN"
HOST=`hostname -s`
SYSTEM_DEF="SYSTEM.FTE."
QLOCAL_TYPES="COMMAND DATA REPLY STATE EVENT AUTHAGT1 AUTHTRN1 AUTHOPS1 AUTHSCH1 AUTHMON1 AUTHADM1"

QMGR_AGENT=$1
AGENT_NAME=$2

if [ -z $AGENT_NAME ]
then
	echo "Must specify Qmanager name for agent"
	exit 1
fi


if [ `dspmq | grep $COORDINATOR | wc -l` == 0 ]
then
        echo "Coordintaror does not exist. Please execute create-coordinator.sh first."
        exit 1
fi

if [ `dspmq | grep $COMMANDER | wc -l` == 0 ]
then
        echo "Commander does not exist. Please execute create-commander.sh first."
        exit 1
fi

if [ `dspmq | grep $AS400_CLIENT | wc -l` == 0 ]
then
        echo "Agent $AS400_CLIENT does not exist. Please execute create-as400-aget.sh first."
        exit 1
fi

if [ `dspmq | grep $QMGR_AGENT | wc -l` == 0 ]
then
        echo "Agent $QMGR_AGENT does not  exist."
        exit 1
fi




for QLOCAL_TYPE in $QLOCAL_TYPES
do 
	echo "Creando QLOCAL: ${SYSTEM_DEF}${QLOCAL_TYPE}.$AGENT_NAME"

	echo "DEFINE QLOCAL(${SYSTEM_DEF}${QLOCAL_TYPE}.$AGENT_NAME) DEFPRTY(0) DEFSOPT(SHARED) GET(ENABLED) MAXDEPTH(5000) \
	MAXMSGL(4194304) MSGDLVSQ(PRIORITY) PUT(ENABLED) RETINTVL(999999999) SHARE NOTRIGGER USAGE(NORMAL) REPLACE " | runmqsc $QMGR_AGENT

done

