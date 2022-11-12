#!/bin/bash

# Este script requiere del Template "Application Server Portal" sea  asignado al server en Zabbix.

#if [ $(id -u) -eq 0 ] ; then
#        echo -e "\n\e[31mNO puede ejecutar el script con ROOT\e[39m"
#        echo -e "\n\e[31mdebe iniciar con el usuario guiadm\e[39m"
#        exit 2
#fi


# En esta variable debe declarar el nombre de los servicios, separados por un espacio
#  Ejemplo: tenemos el systemctl status http y el systemctel status node, entonces los servicios son:
#  httpd y node

NAME_SERVICES="httpd node"

# En estas variables debe declarar los puertos que le corresponden a los servicios antes identificados
#  Ejemplo: El 443 corresponde al httpd, el 8443 corresponde al node

PORTS="443 8443"

##################################################################################
# A continuacion evitar modificar las siguientes lineas
##################################################################################


function status_service {
        if [ ! -z $1 ] ; then
                # echo "Es para sabir Si colocaron argumento"
                NAME_SERVICES="$1"
        fi
        for service in $NAME_SERVICES
        do
                ESTATUS=$(systemctl status $service | grep Active | grep running | wc -l)
                if [ $ESTATUS -ge 1 ] ; then
                        echo -e "\n\e[32mServicio $service esta operativo\e[39m"
                        #send_zabbix  $service.key 0
                        ESTATUS_serv="$service.up"
                else
                        echo -e "\n\e[31mServicio $service esta DOWN\e[39m"
                        #send_zabbix $service.key 1
                        ESTATUS_serv="$service.down"
                fi
        done
}


function zabbix_service {
        if [ ! -z $1 ] ; then
                # echo "Es para sabir Si colocaron argumento"
                NAME_SERVICES="$1"
        fi
        for service in $NAME_SERVICES
        do
                ESTATUS=$(systemctl status $service | grep Active | grep running | wc -l)
                if [ $ESTATUS -ge 1 ] ; then
                        echo "1"
                else
                        echo "0"
                fi
        done
}

function status_port {
        if [ ! -z $1 ] ; then
                # echo "Es para sabir Si colocaron argumento"
                PORTS="$1"
        fi
        for port in $PORTS
        do
                ESTATUS=$(netstat -nat | grep -w $port | wc -l)
                if [ $ESTATUS -ge 1 ] ; then
                        echo -e "\n\e[32mPuerto $port, esta operativo\e[39m"
                        # send_zabbix $port.key 0
                        ESTATUS_port="$port.up"
                else
                        echo -e "\n\e[31mPuerto $port, NO esta iniciado\e[39m"
                        # send_zabbix $port.key 1
                        ESTATUS_port="$port.down"
                fi
        done
}

function zabbix_port {
        if [ ! -z $1 ] ; then
                # echo "Es para sabir Si colocaron argumento"
                PORTS="$1"
        fi
        for port in $PORTS
        do
                ESTATUS=$(netstat -nat | grep -w $port | wc -l)
                if [ $ESTATUS -ge 1 ] ; then
                        echo "1"
                else
                        echo "0"
                fi
        done
}


function send_zabbix {
        zabbix_command=/usr/bin/zabbix_sender
        zabbix_conf=/etc/zabbix/zabbix_agentd.conf
        host=`hostname -s`
        zabbix_key=$1
        zabbix_value=$2
        zabbix_server="SRV-VCCS-ZABBIX"
        $zabbix_command -c $zabbix_conf -z $zabbix_server  -s "$host" -k $zabbix_key -o $zabbix_value > /dev/null
}


function stop {
        for service in $NAME_SERVICES
        do
                systemctl stop $service
                sleep 3
                for i in $(ps -ef | grep $service | grep -v grep); do echo kill -9  $service ; done
        done
}

function start {
        for service in $NAME_SERVICES
        do
                status_service $service
                if [ $ESTATUS_serv == "$service.down" ] ; then
                        echo -e "\n\e[32mSe procede a iniciar el servicio $service porque esta: $ESTATUS_serv\e[39m"
                       systemctl start $service
                fi
        done
}

function restart {
        stop
        sleep 2
        start
}

function discover {
        if [ $1 == "service" ] ;then
                echo '{"data":[' ; for i in $NAME_SERVICES ; do echo '{"{#SERVICE}":"'$i'"},' ; done | sed  '$ s/.$//' ; echo ']}'
        fi
        if [ $1 == "port" ] ;then
                echo '{"data":[' ; for i in $PORTS ; do echo '{"{#PORT}":"'$i'"},' ; done | sed  '$ s/.$//' ; echo ']}'
        fi
}

function autogestion {
        for service in $NAME_SERVICES
        do
                status_service $service
                if [ $ESTATUS_serv == "$service.down" ] ; then
                        echo -e "\n\e[32mSe procede a iniciar el servicio $service porque esta: $ESTATUS_serv\e[39m"
                       systemctl start $service
                fi
        done

}
case "$1" in
    status_service|status_port|start|stop|restart|autogestion|discover|zabbix_service|zabbix_port)
        $1 $2
        ;;
    *)
        echo -e "\n\e[33mComo usar el script: $0 {start|stop|status_service <Name_Service>|status_port <Name_Port>|restart|autogestion|discover}\n\e[39m"
        exit 2
        ;;
esac

