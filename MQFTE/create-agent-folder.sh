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

	echo "fteCreateAgent -agentName $AGENT_NAME -agentQMgr $QMGR_AGENT -agentQMgrHost srv-vccs-mqfteprd -agentQMgrPort $AGENT_PORT -f"

done
