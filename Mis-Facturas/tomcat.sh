#!/bin/bash
### BEGIN INIT INFO
# Provides:          <NAME>
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       <DESCRIPTION>
### END INIT INFO

export JAVA_HOME="/usr/lib/jvm/jre-1.7.0-openjdk.x86_64"
export JAVA_OPTS='-Xms128m -Xmx512m -DBGROOT=/opt/CheckFree/iSeries -DPDROOT=/opt/CheckFree/iSeries'
export JSSE_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75.x86_64/jre/jre/lib/ext/

export PATH="/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin:/usr/lib64/qt-3.3/bin:/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75.x86_64/jre/bin:/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/opt/CheckFree/iSeries/bin:/home/bgadmin/bin"
# . /etc/profile

SCRIPT="/opt/apache-tomcat-7.0.42/bin/catalina.sh"

function IdUser {
    IDUSER=$(id -u)
    if [ ! $IDUSER -eq 502 ] ; then
        echo -e "\e[31mEste comando lo debe ejecutar con bgadmin\e[0m"
        return 10
    fi
}

start() {
  IdUser
  if [ $? -eq 10 ] ; then
    exit 1
  fi
  echo 'Starting service' >&2
  $SCRIPT start
  echo 'Service started' >&2
}

stop() {
  IdUser
  if [ $? -eq 10 ] ; then
    exit 1
  fi
  $SCRIPT stop
  echo 'Stopping service' >&2
  sleep 10 
  # for i in $(ps -ef | grep -v grep | grep -v tail | grep catalina | awk '{print $2}')
  for i in $(ips -ef | grep -v grep | grep -v catalina.out | grep jakarta | awk '{print $2}')
  do
     kill -9 $i
  done
  #sync; echo 1 > /proc/sys/vm/drop_caches
  rm -rf /opt/apache-tomcat-7.0.42/work/Catalina
  echo 'Service stopped' >&2
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    sleep 10
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
esac

