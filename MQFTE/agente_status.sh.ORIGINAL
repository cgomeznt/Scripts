#!/bin/bash

/opt/mqm/bin/fteListAgents | egrep -v 'Copyright|WebSphere|Manager' | awk '{print $1 ":" $2}' > /tmp/fteListAgents.txt

for i in `cat /tmp/fteListAgents.txt` 
do
MQM=`echo $i | awk -F":" '{print $2}'`
AGENT=`echo $i | awk -F":" '{print $1}'`
# echo $i
# echo "$MQM $AGENT"
if [ $AGENT == "BAV01AGN.AG" ] ; then
   echo "0" > /tmp/$AGENT.txt 
else
/opt/mqm/bin/ftePingAgent -w 35 -m $MQM $AGENT | grep responded &> /dev/null
if [ $? -eq 0 ] ; then
   # echo "0"
   echo "0" > /tmp/$AGENT.txt
else
   # echo "1"
   echo "1" > /tmp/$AGENT.txt
fi
fi
done
