#!/bin/sh
#
# NOC-ISP
# Cantv.net - Noviembre del 2001
# Modificado el 20/05/2008 por Ender Mujica emujica@cantv.net 
#
# Valor 1 = Conexiones HTTP actuales
# Valor 2 = Conexiones FTP actuales
# Valor 3 = Conexiones Concurrentes Maximas alcanzadas por un cliente Web Individual
# Valor 4 = Conexiones HTTP actuales (solo establecidas)
# Valor 5 = Conexiones FTP actuales (solo establecidas)
# Valor 6 = Conexiones HTTP en estado SYN_RECV
# Valor 7 = Conexiones FTP en estado SYN_RECV

PATH=$PATH:/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin

if [ -z $1 ]
then
  echo "Debe indicar al menos un puerto."
  echo -e "\tEj: conexiones.puerto.sh 80"
  echo -e "\t    conexiones.puerto.sh 8009"
  echo -e "\t    conexiones.puerto.sh 25"
  exit 1 
fi

 
out=`netstat -an|egrep '(udp|tcp)'|grep -v "*.*"`
outlocalAddress=`echo "$out" |awk {'print $4":"$5":"$6'}|awk -F":" {'print $1":"$2" "$3" "$5'}`
outforeingAddress=`echo "$out" |awk {'print $4":"$5":"$6'}|awk -F":" {'print $1" "$3":"$4" "$5'}`

#var1=`echo "$out"|grep ":$1"|awk '{print $5}'|sed s/\:\:ffff\://g|cut -d: -f1|sort -rn|uniq -c|sort -rn|head -n 1| awk '{print $1}'`
maxconnfromclient=`echo "$outlocalAddress"|grep ":$1"|egrep '(ESTABLISHED|SYN_RECV|TIME_WAIT)' | grep -v "127.0.0.1"|awk '{print $2}'|sed s/\:\:ffff\://g|cut -d: -f1|sort -rn|uniq -c|sort -rn|head -n 1| awk '{print $1}'`
maxconntoserver=`echo "$outforeingAddress"|grep ":$1"|egrep '(ESTABLISHED|SYN_RECV|TIME_WAIT)' | grep -v "127.0.0.1"|awk '{print $2}'|sed s/\:\:ffff\://g|cut -d: -f1|sort -rn|uniq -c|sort -rn|head -n 1| awk '{print $1}'`

if [ -z $maxconnfromclient ]
then
        maxconnfromclient="0"
fi

if [ -z $maxconntoserver ]
then
        maxconntoserver="0"
fi


echo "$outlocalAddress"|awk '{print $1}'|egrep -c ":$1$"

if [ $1 == "80" ]
then
   echo "$outlocalAddress"|awk '{print $1}'|egrep -c ':(20|21)$'
fi  

echo "$maxconnfromclient"

echo "$outlocalAddress"|grep "ESTABLISHED"|awk '{print $1}'|egrep -c ":$1$"

if [ $1 == "80" ]
then
   echo "$outlocalAddress"|grep "ESTABLISHED"|awk '{print $1}'|egrep -c ':(20|21)$'
fi  


echo "$outlocalAddress"|grep "SYN_RECV"|awk '{print $1}'|egrep -c ":$1$"

if [ $1 == "80" ]
then
    echo "$outlocalAddress"|grep "SYN_RECV"|awk '{print $1}'|egrep -c ':(20|21)$'
fi  

echo "$maxconntoserver"
