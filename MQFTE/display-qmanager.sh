#/bin/bash

GREEN="\e[0;32m"
NORMAL="\e[0m"
RED="\e[0;31m"
BLUE="\e[36m"
YELLOW="\e[33m"



for Q in `dspmq | awk {'print $1'}`
do 

	QMANAGER=`echo $Q | awk {'print $1'} | awk -F "QMNAME" {'print $2'} | sed s/\)//g | sed s/\(//g` 
	STATUS=`dspmq | grep $QMANAGER | awk {'print $2$3'} | awk -F "STATUS" {'print $2$3'} | sed s/\)//g | sed s/\(//g`
	#STATUS=`dspmq | grep $QMANAGER | awk {'print $2'}`

	case "$STATUS" in

		"Running")
			COLOR=$GREEN
		;;
		"Endednormally")
			COLOR=$YELLOW
		;;
		*)
			COLOR=$RED
		;;
	esac
	
	echo -e "${COLOR}${QMANAGER}${NORMAL}"
	

done
