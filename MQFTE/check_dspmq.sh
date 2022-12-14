#!/bin/bash

ZABBIX_SRV="srv-vccs-zabbix.credicard.com.ve"
HOSTNAME=`hostname -s`
TEMP="/tmp"
TEMP_STATUS="$TEMP/check_dspmq.txt"
QMNAME=""

function zabbix_Sender {
    /usr/bin/zabbix_sender -z $ZABBIX_SRV -s $HOSTNAME -k $1 -o $2 &> /dev/null
}

function verfica_Reportados {
    REPORTADO=$(cd /tmp && ls *.reportado | awk -F"." '{print $1}')
    for REPORTADO_QMNAME in $REPORTADO
    do
       grep $REPORTADO_QMNAME $TEMP_STATUS &> /dev/null
       if [ ! $? -eq 0 ]; then
          zabbix_Sender $REPORTADO_QMNAME 1
          rm -f $TEMP/$REPORTADO_QMNAME.reportado
          # echo -e "$TEMP/$REPORTADO_QMNAME"
       fi
    done
}

function ver_Colas {
   dspmq > $TEMP_STATUS

}

function ver_Status {
    QMNAME=$(grep -vi "running" $TEMP_STATUS | awk '{print $1}' | awk -F"(" '{print $2}' | tr -d ")")
}


ver_Colas
ver_Status

for WAR_QMNAME in $(echo "$QMNAME")
do
   # echo "$WAR_QMNAME debe reportarse"
   zabbix_Sender $WAR_QMNAME 0
   touch $TEMP/$WAR_QMNAME.reportado
done

verfica_Reportados

