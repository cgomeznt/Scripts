#!/bin/bash

if [ "`whoami`" != "mqm" ];then
        echo -e "${RED}ERROR:${NORMAL}Este comando debe ser ejecutado con el usuario mqm"
        exit 1
fi


/opt/mqm/bin/fteCreateLogger -loggerType FILE -fileLoggerMode CIRCULAR -fileSize 50MB -fileCount 10 filelogger1

sleep 2

runmqsc $COORDINATOR < /var/mqm/mqft/config/CRC01CRD/loggers/FILELOGGER1/FILELOGGER1_create.mqsc
