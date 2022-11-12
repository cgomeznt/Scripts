#!/bin/bash

AGENT_LIST="/usr/local/bin/agents.lst"
DEF_AGENT_FTE="/usr/local/bin/agent_def.sh"
HOST=`hostname -s`

if [ ! -f $AGENT_LIST ]
then
	echo "ERROR: No existe el archivo $AGENT_LIST"
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



for  AGENT  in `cat $AGENT_LIST | grep -v "#"`
do
	
	QMGR_AGENT=`echo $AGENT | grep -v "#" | awk -F\: {'print $1'}`
	AGENT_COMMENT=`echo $AGENT |  grep -v "#" | awk -F\: {'print $2'}`
	AGENT_PORT=`echo $AGENT |  grep -v "#" | awk -F\: {'print $3'}`
	AGENT_NAME=`echo $AGENT |  grep -v "#" | awk -F\: {'print $4'}`

	EXIST=`dspmq | grep $QMGR_AGENT | wc -l`
	

	if [ "$EXIST" == "0" ]
	then 

		crtmqm -c "$AGENT_COMMENT" $QMGR_AGENT
		strmqm $QMGR_AGENT
		runmqsc $QMGR_AGENT << EOF
			DEFINE LISTENER ($QMGR_AGENT.LST) TRPTYPE (TCP) CONTROL (QMGR) PORT ($AGENT_PORT)
			START LISTENER ($QMGR_AGENT.LST)
			DEFINE CHANNEL (SYSTEM.ADMIN.SVRCONN) CHLTYPE (SVRCONN)
			START CHANNEL (SYSTEM.ADMIN.SVRCONN)
			DEFINE QLOCAL ($QMGR_AGENT.DQ) USAGE (NORMAL)
			ALTER QMGR DEADQ($QMGR_AGENT.DQ)
			ALTER QMGR  CHLAUTH(DISABLED)
	                SET CHLAUTH(*)  TYPE(BLOCKUSER) USERLIST(*MQADMIN) ACTION(REMOVE)
        	        SET CHLAUTH(*)  TYPE(ADDRESSMAP) ADDRESS(*)  USERSRC(CHANNEL) ACTION(ADD)
			SET CHLAUTH(SYSTEM.*) TYPE(ADDRESSMAP) ADDRESS(*) USERSRC(CHANNEL) ACTION(REPLACE)
	                ALTER AUTHINFO('SYSTEM.DEFAULT.AUTHINFO.IDPWOS') AUTHTYPE(IDPWOS) CHCKCLNT(NONE)
			ALTER CHANNEL(SYSTEM.ADMIN.SVRCONN) CHLTYPE(SVRCONN) MCAUSER('usrmq')
			ALTER CHANNEL(SYSTEM.DEF.SVRCONN) CHLTYPE(SVRCONN) MCAUSER('usrmq')
        	        REFRESH SECURITY TYPE(CONNAUTH)



			DEFINE CHANNEL ($QMGR_AGENT.A.CRC01CRD) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($COORDINATOR_PORT)') XMITQ ($COORDINATOR)
			DEFINE CHANNEL (CRC01CRD.A.$QMGR_AGENT) CHLTYPE (RCVR)
			DEFINE QLOCAL ($COORDINATOR) USAGE (XMITQ)

			DEFINE CHANNEL ($QMGR_AGENT.A.CRC01CMM) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($COMMANDER_PORT)') XMITQ ($COMMANDER)
			DEFINE CHANNEL (CRC01CMM.A.$QMGR_AGENT) CHLTYPE (RCVR)
			DEFINE QLOCAL ($COMMANDER) USAGE (XMITQ)

			DEFINE CHANNEL ($QMGR_AGENT.A.CRC03AGN) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($AS400_CLIENT_PORT)') XMITQ ($AS400_CLIENT)
			DEFINE CHANNEL (CRC03AGN.A.$QMGR_AGENT) CHLTYPE (RCVR)
			DEFINE QLOCAL ($AS400_CLIENT) USAGE (XMITQ)
			END
EOF

		echo "";echo "";echo "";echo ""
		echo "Definir qmanager en el coordinator"
		echo "Creando definiciones en el COORDINATOR ($COORDINATOR) para el agente $QMGR_AGENT"	

		runmqsc $COORDINATOR << EOF
		DEFINE CHANNEL (CRC01CRD.A.$QMGR_AGENT) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($AGENT_PORT)') XMITQ ($QMGR_AGENT)
		DEFINE QLOCAL ($QMGR_AGENT) USAGE (XMITQ)
		DEFINE CHANNEL ($QMGR_AGENT.A.CRC01CRD) CHLTYPE (RCVR)
		END

EOF

		echo "";echo "";echo "";echo ""
		echo "Definir qmanager en el commander"
		echo "Creando definiciones en el COMMANDER ($COMMANDER) para el agente $QMGR_AGENT"	

		runmqsc $COMMANDER << EOF
		DEFINE CHANNEL (CRC01CMM.A.$QMGR_AGENT) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($AGENT_PORT)') XMITQ ($QMGR_AGENT)
		DEFINE QLOCAL ($QMGR_AGENT) USAGE (XMITQ)
		DEFINE CHANNEL ($QMGR_AGENT.A.CRC01CMM) CHLTYPE (RCVR)
		END

EOF

		echo "";echo "";echo "";echo ""
		#Definir qmanager en el as400
		echo "Creando definiciones en el AS400 ($AS400_CLIENT) para el agente $QMGR_AGENT"	

		runmqsc $AS400_CLIENT << EOF
		DEFINE CHANNEL (CRC03AGN.A.$QMGR_AGENT) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($AGENT_PORT)') XMITQ ($QMGR_AGENT)
		DEFINE QLOCAL ($QMGR_AGENT) USAGE (XMITQ)
		DEFINE CHANNEL ($QMGR_AGENT.A.CRC03AGN) CHLTYPE (RCVR)
		END
EOF


		
		# Creamos la deficion de las colas de FTE en el Qmanager del Agente.
		echo "########################################################################################"
		echo "#Llamando a la deficion para las colas de FTE                                          #"
		echo "########################################################################################"
		$DEF_AGENT_FTE $QMGR_AGENT $AGENT_NAME


	else
		echo "El Qmanager para el agente $QMGR_AGENT ya existe."

	fi


done

