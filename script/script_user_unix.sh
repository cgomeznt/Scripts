[root@lcsprdapptdldap01 cgomez]# cat script_user_unix.sh
#!/bin/bash
###############################################################
### Script para creaciÃ³n de usuarios Soporte Unix Credicard ###
###############################################################

###############################################################
# VARIABLES #
#############
HOSTNAME=`hostname`
PASSWORD=credicard
DATE=`date "+%Y%m%d"`
export PASSWORD
PASSWD_ECRYP=`openssl passwd -1 -salt xyz "$PASSWORD"`

export PASSWD_ECRYP HOSTNAME DATE

###############################################################
useradd  -g soinfra -c " Tomas Diaz - Administrador S.O." -m -d /home/tdiazm tdiazm -p $PASSWD_ECRYP
useradd  -g soinfra -c " Yohanmeibis Simancas - Administrador S.O." -m -d /home/ysimanc  ysimanc -p $PASSWD_ECRYP
useradd  -g soinfra -c " Ruben Barradas - Administrador S.O." -m -d /home/rbarra  rbarra -p $PASSWD_ECRYP
useradd  -g soinfra -c " Rafael Mendoza - Administrador S.O." -m -d /home/rmendoza  rmendoza -p $PASSWD_ECRYP
useradd  -g soinfra -c " Frank Badilla - Administrador S.O." -m -d /home/fbadilla  fbadilla -p $PASSWD_ECRYP
##############################################################
echo -e " \n ContraseÃ±a por defecto es: $PASSWORD"

chage -d0 tdiazm
chage -d0 ysimanc
chage -d0 rbarra
chage -d0 rmendoza
chage -d0 fbadilla
##############################################################
echo -e "\n Ha Finalizado la creaciÃ³n de usuarios $DATE \n"
##############################################################
# ENVIO DE CORREO DE CONFIRMACIÃN #
###################################
#echo "Se ha creado los usuarios de Soporte Unix en el servidor $HOSTNAME" | mailx -s "Usuarios Creados en Servidor $HOSTNAME $DATE" soporte.unix@credicard.com.ve
##############################################################
# FINALIZA SCRIPT ~ soporte unix Credicard ~ 2019 ~ T.A.D.M. #
##############################################################
