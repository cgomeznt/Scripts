#!/bin/bash

VALUE=`/opt/mqm/bin/fteShowLoggerDetails filelogger1  | grep "Status:" | grep "STARTED" | wc -l`

echo $VALUE > /var/tmp/fteLoggerStatus.txt

/usr/bin/zabbix_sender  -z zabbix.credicard.com.ve -s srv-vccs-mqfteprd -k fteLoggerStatus -o $VALUE

