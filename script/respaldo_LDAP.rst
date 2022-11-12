[root@lcsprdapptdldap01 cgomez]# cat /usr/local/bin/respaldo_mantenimiento_ldap.sh

#!/bin/bash
#Coordinacion Soporte Web
#Date 24-05-2021
#Script de Mantenimiento y Respaldo de Servicio OpenLDAP

#########Respaldo de LDAP##############################
TMP_FILE=/opt/respaldoLDAP
SCRIPT=respaldo_mantenimiento_ldap.sh
LDAP_CONFIG=config_$(date +%H:%M_%d-%m-%Y).ldif
LDAP_DATA=data_$(date +%H:%M_%d-%m-%Y).ldif

############ZABBIX#######################################
ZBX_FILE=/etc/zabbix/zabbix_agentd.conf
ZBX_BIN=/usr/bin/zabbix_sender
ZBX_HOST='SRV-VCCS-ZABBIX'
HOST=$(hostname -s)

######Depuracion LOGS de Transacionales del LDAP##########
BIN=/usr/bin
RUT_LIB=/var/lib/ldap



function respaldo_config_LDAP {
        slapcat -v -n 0 -l $TMP_FILE/$LDAP_CONFIG
              sleep 5
                if [ -f $TMP_FILE/$LDAP_CONFIG ]
                   then
                    gzip -9 $TMP_FILE/$LDAP_CONFIG
                        logger -t $SCRIPT -p local0.info "[info] Respaldo de Configuracion del LDAP termino de forma satifactoria"
                                $ZBX_BIN -c $ZBX_FILE -s $HOST -k STATUS_RESPALDO_CONF -o 1
                 else
                        logger -t $SCRIPT -p local0.err "[err] Respaldo de Configuracion del LDAP no se completo de manera exitosa"
                                $ZBX_BIN -c $ZBX_FILE -s $HOST -k STATUS_RESPALDO_CONF -o 0
                fi

}

function respaldo_data_LDAP {
        slapcat -v -n 2 -l $TMP_FILE/$LDAP_DATA
            sleep 5
                if [ -f $TMP_FILE/$LDAP_DATA ]
                   then
                    gzip -9 $TMP_FILE/$LDAP_DATA
                        logger -t $SCRIPT -p local0.info "[info] Respaldo de Data de LDAP  termino de forma satifactoria"
                                $ZBX_BIN -c $ZBX_FILE -s $HOST -k STATUS_RESPALDO_DATA -o 1
                else
                        logger -t $SCRIPT -p local0.err "[err] Respaldo de Data del LDAP no se completo de manera exitosa"
                                $ZBX_BIN -c $ZBX_FILE -s $HOST -k STATUS_RESPALDO_DATA -o 0
                fi
}

function depuracion_Backup_LDAP {
        find $TMP_FILE -mtime +4 | xargs rm -f {} \;
                logger -t $SCRIPT -p local0.info "[info] Se culmino la depuracion de los Backup de Configuracion y Data del LDAP Mayor 4 dias"

}

function depuracion_logs_LDAP {
    cd $RUT_LIB
        $BIN/db_checkpoint -1; $BIN/db_archive -d -h $RUT_LIB
                logger -t $SCRIPT -p local0.info "[info] Se culmino la Depuracion de los LOGS Transaccionales de LDAP que ya se encuentra Obsoleto"
}

function limpieza_cache {
        echo 3 > /proc/sys/vm/drop_caches && sync
           logger -t $SCRIPT -p local0.info "[info] Depuracion de la Memoria Cache Obseleta del Servidor"
}

##################################Ejecucion de Proceso de LDAP################
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
#############################################################################
respaldo_config_LDAP > /dev/null
respaldo_data_LDAP > /dev/null
depuracion_Backup_LDAP
depuracion_logs_LDAP
limpieza_cache
exit 0;
