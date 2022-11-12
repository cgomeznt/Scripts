#!/bin/bash

GREEN="\e[0;32m"
NORMAL="\e[0m"
RED="\e[0;31m"
BLUE="\e[36m"

QMANAGER=$1

if [ "`whoami`" != "mqm" ];then
	echo -e "${RED}ERROR:${NORMAL}Este comando debe ser ejecutado con el usuario mqm"
	exit 1
fi 


if [ -z $QMANAGER ];then
	echo -e "${RED}ERROR:${NORMAL} You must specify QMANAGER"
	exit 1
fi 

echo ""

echo -e "QMANAGER: ${BLUE}$QMANAGER${NORMAL}"

for CHANNEL in `echo "display channel(*)" | runmqsc $QMANAGER | grep -v SYST | grep CHLTYPE | awk {'print $1'} | awk -F\( {'print $2'} | sed s/\)//g`
do
	

	echo -e "\t\t${BLUE}$CHANNEL${NORMAL}"



#	STRING=`echo -n "display chstatus($CHANNEL)" | runmqsc $QMANAGER | egrep "CHANNEL|STATUS|SUBSTATE" | awk {'print $1 " " $2'}`
#	
#	if [ "x$STRING" == "x" ];
#	then
#		STATUS="NOT INFORMATION"
#		COLOR=$RED
#
#	else
#	
#		COLOR=$GREEN
#		CHLTYPE=`echo $STRING | awk {'print $2'}`
#                RQMNAME=`echo $STRING | awk {'print $3'}`
#                STATUS=`echo $STRING | awk {'print $4'}`
#                SUBSTATE=`echo $STRING | awk {'print $5'}`
#
#	fi
#
#	echo -e "$CHANNEL\t$CHLTYPE\t$RQMNAME\t${COLOR}$STATUS${NORMAL}\t$SUBSTATE"
#
#
#
#	unset COLOR
#	unset CHLTYPE
#	unset RQMNAME
#	unset STATUS
#	unset SUBSTATE
#	unset STRING
#
done


echo ""
