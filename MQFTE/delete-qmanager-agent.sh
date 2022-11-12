#!/bin/bash

AGENT=$1
HOST=`hostname -s`


################################################################################################
#Funciones 
################################################################################################
function deleteChannels() {

	NAME=$1
	QNAME=$2
	
	echo $QNAME

	if [ "`dspmq | grep $QNAME | grep Running | wc -l`" == "1" ]
	then
		echo "Deleting Qlocal in $NAME: $QNAME for Qmanager Agent $AGENT"
		if [ "`echo "display queue(*)" | runmqsc $QNAME | grep $AGENT | wc -l`" == 1 ]
		then
			echo "delete qlocal($AGENT)" | runmqsc $QNAME
			echo "Qlocal in $NAME: $QNAME was deleted"
		else
			echo "Does not exist Queue Local in $NAME: $QNAME for Qmanager Agent $AGENT"
		fi


		echo "Deleting Channels in $NAME: $QNAME"
		if [ "`echo "display channel(*)" | runmqsc $QNAME | grep $AGENT | wc -l`" == 0 ]
		then
			echo "Does not exist Channels in $NAME $QNAME for Qmanager Agent $AGENT"
		else
			for q in  `echo "display channel(*)" | runmqsc $QNAME | grep $AGENT | awk '{print $1}' | sed s/CHANNEL\(//g | sed s/\)//g`
			do
				echo "Deleting channel $q in $NAME $QNAME"
				echo "delete channel($q)" | runmqsc $QNAME
				echo "Channel $q in $NAME $QNAME Deleted"
			done
		fi
	else
		echo "ERROR: qmanager $NAME $QNAME  is not Running, can not delete channel."
	fi

}


################################################################################################
# Cuerpo del Script
################################################################################################


if [ -z $AGENT ]
then
	echo "ERROR: You Must specify qmanager agent name."
	exit 1
fi

if [ `dspmq | grep $AGENT | wc -l` == 0 ]
then
        echo "ERROR: qmanager agent specified does not exit."
else
	echo "Stopping qmanager agent $AGENT"
	if [ "`dspmq | grep $COORDINATOR | grep Running |  wc -l`" == 0 ]
	then
		echo "Qmanager  agent $AGENT is alredy stopped"
	else
		
		endmqm $AGENT
		echo "Ending Qmanager Agent $AGENT"
		until [ "$ENDED" == "Ended" ]
		do 
			sleep 1
			ENDED=`dspmq  | grep Ended | awk {'print $2'} | sed s/STATUS\(//g`
		done

		echo "Qmanager Agent $AGENT waas Ending succesfully"
	fi
	echo "Deleting Qmanager Agent $AGENT"
	dltmqm $AGENT
fi


for i in $COORDINATOR $COMMANDER $AS400_CLIENT 
do
	case $i in 
	$COORDINATOR)
		NAME="Coordinator"
		QNAME=$COORDINATOR
		;;
	$COMMANDER)
		NAME="Commander"
		QNAME=$COMMANDER
		;;
	$AS400_CLIENT)
		NAME="AS400_CLIENT"
		QNAME=$AS400_CLIENT
	;;
	esac


	deleteChannels $NAME $QNAME 

done




