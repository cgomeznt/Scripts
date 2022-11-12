#!/bin/bash

CHANNEL="SYSTEM.ADMIN.SVRCONN"
HOST=`hostname -s`


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



# Creando canales desde el agente AS400 al COORDINATOR y COMMANDER
# 
# 
echo ""
echo ""
echo ""
echo "Creating Channels for $AS400_CLIENT"
runmqsc $AS400_CLIENT << EOF
	DEFINE CHANNEL (CRC03AGN.A.CRC01CRD) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($COORDINATOR_PORT)') XMITQ ($COORDINATOR)
	DEFINE QLOCAL ($COORDINATOR) USAGE (XMITQ)

	DEFINE CHANNEL (CRC01CRD.A.CRC03AGN) CHLTYPE (RCVR)

	DEFINE CHANNEL (CRC03AGN.A.CRC01CMM) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($COMMANDER_PORT)') XMITQ ($COMMANDER)
	DEFINE QLOCAL ($COMMANDER) USAGE (XMITQ)
	
	DEFINE CHANNEL (CRC01CMM.A.CRC03AGN) CHLTYPE (RCVR)
	END

EOF





# Creando Canales desde el COORDINATOR al AS400 y el COMMANDER
echo ""
echo ""
echo ""
echo "Creating Channels for $COORDINATOR"
runmqsc $COORDINATOR << EOF
	DEFINE CHANNEL (CRC01CRD.A.CRC03AGN) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($AS400_CLIENT_PORT)') XMITQ ($AS400_CLIENT)
	DEFINE QLOCAL ($AS400_CLIENT) USAGE (XMITQ)

	DEFINE CHANNEL (CRC03AGN.A.CRC01CRD) CHLTYPE (RCVR)

	DEFINE CHANNEL (CRC01CRD.A.CRC01CMM) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($COMMANDER_PORT)') XMITQ ($COMMANDER)
	DEFINE QLOCAL ($COMMANDER) USAGE (XMITQ)

	DEFINE CHANNEL (CRC01CMM.A.CRC01CRD) CHLTYPE (RCVR)
	END
EOF



# Crenado Canales desde el COMMANDER al AS400 y COORDINATOR
echo ""
echo ""
echo ""
echo "Creating Channels for $COMMANDER"
runmqsc $COMMANDER << EOF
	DEFINE CHANNEL (CRC01CMM.A.CRC03AGN) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($AS400_CLIENT_PORT)') XMITQ ($AS400_CLIENT)
	DEFINE QLOCAL ($AS400_CLIENT) USAGE (XMITQ)

	DEFINE CHANNEL (CRC03AGN.A.CRC01CMM) CHLTYPE (RCVR)

	DEFINE CHANNEL (CRC01CMM.A.CRC01CRD) CHLTYPE (SDR) DISCINT(0) CONNAME ('$HOST($COORDINATOR_PORT))') XMITQ ($COORDINATOR)
	DEFINE QLOCAL ($COORDINATOR) USAGE (XMITQ)

	DEFINE CHANNEL (CRC01CRD.A.CRC01CMM) CHLTYPE (RCVR)
	END
EOF

echo ""
echo "Stating Channels $COMMANDER"
runmqsc $COMMANDER << EOF
	START CHANNEL (CRC01CMM.A.CRC03AGN)
	START CHANNEL (CRC01CMM.A.CRC01CRD)
EOF

echo "Stating Channels $COORDINATOR"
runmqsc $COMMANDER << EOF
	START CHANNEL (CRC01CRD.A.CRC03AGN)
	START CHANNEL (CRC01CRD.A.CRC01CMM)

EOF

echo "Stating Channels $AS400_CLIENT"
runmqsc $COMMANDER << EOF
	START CHANNEL (CRC03AGN.A.CRC01CRD)
	START CHANNEL (CRC03AGN.A.CRC01CMM)

EOF

echo ""
echo ""
echo "END....END..!!!!!!!!!!!!!!"

