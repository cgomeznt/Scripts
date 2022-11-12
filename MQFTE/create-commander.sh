#!/bin/bash

#echo $COMMANDER
FTE_CMD="/opt/mqm/bin/"
EXIST=`dspmq | grep $COMMANDER | wc -l`
CHANNEL="SYSTEM.ADMIN.SVRCONN"
HOST=`hostname -s`

if [ `dspmq | grep $COORDINATOR | wc -l` == 0 ]
then
	echo "Coordintaror does not exist. Please execute create-coordinator.sh first."
	exit 1
fi

if [ "$EXIST" == "0" ]
then 

	crtmqm -c "Commander" $COMMANDER
	strmqm $COMMANDER
	runmqsc $COMMANDER << EOF
		DEFINE LISTENER ($COMMANDER.LST) TRPTYPE (TCP) CONTROL (QMGR) PORT ($COMMANDER_PORT)
		START LISTENER ($COMMANDER.LST)
		DEFINE CHANNEL ($CHANNEL) CHLTYPE (SVRCONN)
		START CHANNEL ($CHANNEL)
		DEFINE QLOCAL ($COMMANDER.DQ) USAGE (NORMAL)
		ALTER QMGR DEADQ($COMMANDER.DQ)
		ALTER QMGR  CHLAUTH(DISABLED)
                SET CHLAUTH(*)  TYPE(BLOCKUSER) USERLIST(*MQADMIN) ACTION(REMOVE)
                SET CHLAUTH(*)  TYPE(ADDRESSMAP) ADDRESS(*)  USERSRC(CHANNEL) ACTION(ADD)
		SET CHLAUTH(SYSTEM.*) TYPE(ADDRESSMAP) ADDRESS(*) USERSRC(CHANNEL) ACTION(REPLACE)
                ALTER AUTHINFO('SYSTEM.DEFAULT.AUTHINFO.IDPWOS') AUTHTYPE(IDPWOS) CHCKCLNT(NONE)
		ALTER CHANNEL(SYSTEM.ADMIN.SVRCONN) CHLTYPE(SVRCONN) MCAUSER('usrmq')
		ALTER CHANNEL(SYSTEM.DEF.SVRCONN) CHLTYPE(SVRCONN) MCAUSER('usrmq')
                REFRESH SECURITY TYPE(CONNAUTH)
EOF

	echo "######################################################################"
	echo "Ejecutando Comando para crear el Commander"
	${FTE_CMD}fteSetupCommands -f -connectionQMgr $COMMANDER -connectionQMgrHost $HOST -connectionQMgrPort $COMMANDER_PORT -connectionQMgrChannel $CHANNEL 

else
	echo "The commander $COMMANDER already exists."

fi
