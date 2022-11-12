#/bin/bash

HOSTNAME=$(hostname -s)
SERVER_ZABBIX="10.133.0.54"
NAME_SCRIPT=$(basename $0)
SEND_ZABBIX=0

usage() {
	echo -e "\e[32mComo Usar: $NAME_SCRIPT [[-z send-Zabbix] | [-h help]]\e[0m\n"
}

function Validar_Nodes {
	KEY="Validar_Nodes"
	if [ $(sudo /usr/bin/kubectl get nodes | wc -l) -eq 7 ] ; then
		echo -e "\e[32mExisten seis (6) nodos, estamos bien\e[0m\n"
		VALOR=0
	else
		MENSAJE=$(echo "Error, faltan nodos, deben existir seis (6)" | tee)
		echo -e "\e[31m$MENSAJE\e[0m\n"
		VALOR=1
		Escribe_Log
	fi
	if [ $SEND_ZABBIX -eq 1 ]; then
		Send_Zabbix
	fi
	echo ""
}

function Validar_Deploy {
	KEY="Validar_Deploy"
	if [ $(sudo /usr/bin/kubectl get deploy | wc -l) -eq 4 ] ; then
		echo -e "\e[32mExisten tres (3) Deploy, estamos bien\e[0m\n"
		VALOR=0
	else
		MENSAJE=$(echo "Error, faltan deploy, deben existir tres (3)" | tee)
		echo -e "\e[31m$MENSAJE\e[0m\n"
		VALOR=1
		Escribe_Log
	fi
	if [ $SEND_ZABBIX -eq 1 ]; then
		Send_Zabbix
	fi
	echo ""
}
	
function Validar_Service {
	KEY="Validar_Service"
        if [ $(sudo /usr/bin/kubectl get service | wc -l) -eq 5 ] ; then
                echo -e "\e[32mExisten tres (3) Service, estamos bien\e[0m\n"
		VALOR=0
        else
                MENSAJE=$(echo "Error, faltan service, deben existir tres (3)" | tee)
		echo -e "\e[31m$MENSAJE\e[0m\n"
		VALOR=1
		Escribe_Log
        fi
	if [ $SEND_ZABBIX -eq 1 ]; then
		Send_Zabbix
	fi
	echo ""
}

function Validar_Pod {
	KEY="Validar_Pod"
	if [ $(sudo /usr/bin/kubectl get pod | wc -l) -eq  10 ] ; then
		echo -e "\e[32mExisten nueve (9) Pod, estamos bien.\e[0m\n"
		VALOR=0
	else
		MENSAJE=$(echo "Error, faltan pod, deben existir nueve (9)" | tee)
		echo -e "\e[31m$MENSAJE\e[0m\n"
		VALOR=1
		Escribe_Log
	fi
	if [ $SEND_ZABBIX -eq 1 ]; then
		Send_Zabbix
	fi
	echo ""
}

function Send_Zabbix {
	echo "/usr/bin/zabbix_sender -z $SERVER_ZABBIX -s $HOSTNAME -k $KEY -o $VALOR -vv"
	/usr/bin/zabbix_sender -z $SERVER_ZABBIX -s $HOSTNAME -k $KEY -o $VALOR -vv
}

function Escribe_Log {
	sudo /usr/bin/logger -t $NAME_SCRIPT -p local0.info "[info] $MENSAJE - Soporte Web"
}
echo ""

# Reading parameters...

while [ "$1" != "" ]; do
    case $1 in
        -z | --send-zabbix )        shift
                                    SEND_ZABBIX=1
                                    ;;
        -h | --help )               usage
                                    exit
                                    ;;
        * )                         usage
                                    exit 1
    esac
    shift
done

Validar_Nodes
Validar_Deploy
Validar_Service
Validar_Pod
