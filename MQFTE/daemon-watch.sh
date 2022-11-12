#!/bin/sh
#
# Generic watchdog for "SYS-V" Unix Systems
# (requires daemon initialization scripts with "start" command
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

DaemonToTest=$1
DaemonStart=$2

# AmIRunning=`ps -ef|grep $DaemonToTest|grep -v grep|wc -l|awk '{print $1}'`


if [ -z $DaemonToTest  ]
then
	echo ""
	echo "Usage: $0 DaemonToTest DaemonScript"
	echo "where:"
	echo "DaemonToTest is the daemon name as it's seen on ps command"
	echo "DaemonScript is the daemon starter script normally on init.d"
	echo "using test as DaemonScript shows the status od the daemon"
	echo ""
	echo "Sample: $0 named test"
	echo ""
	exit "0"
else
	RunTest=`ps -ef|grep $DaemonToTest|grep -v grep|grep -v $0|wc -l|awk '{print $1}'`
fi

if [ -z $DaemonStart ]
then
	exit "0"
else
	case $DaemonStart in

	"test")
		if [ $RunTest -eq "0" ]
		then
			echo ""
			echo "Daemon $DaemonToTest NOT RUNNING"
			echo ""
		else
			echo ""
			echo "Daemon $DaemonToTest running $RunTest instance(s)"
			echo ""
		fi
		;;
	*)
		if [ $RunTest -eq "0" ]
		then
			$DaemonStart stop
			$DaemonStart stop
			$DaemonStart start
		fi
		;;
	esac
fi
