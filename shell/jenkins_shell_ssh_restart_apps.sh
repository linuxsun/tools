#!/usr/bin/env bash

dHost='1.2.3.4'
port='22'
dUser='admin'
appName="server-rpc-myapp-*-SNAPSHOT.jar"
appName=$(ls ${WORKSPACE}/$appName|tail -n -1)
echo "$appName"
appName=$(echo ${appName##*/})
destDir="/tmp/rpc"

echo "send: ${appName}"
scp "-P $port" ${WORKSPACE}/$appName $dUser@$dHost:$destDir/$appName

echo "restart: ${appName}"
myPID=$(ssh -p $port $dUser@$dHost "ps -ef |grep java |grep $appName|grep -v grep |awk '{print \$2}'")
for pid in ${myPID} ; do
  ssh -p $port $dUser@$dHost "ps -f -p $pid >/dev/null 2>&1 && kill -9 $pid || echo 'pid null'"
done
ssh -p $port $dUser@$dHost "nohup java -jar $destDir/$appName >/dev/null 2>&1 &"

# 一行命令kill java rpc 进程
unset mypid upid; mypid=(`ps -ef |grep java|grep rpc|awk '{print $2}'`) ; for upid in ${mypid[@]}; do   if [ "$upid" ]; then     kill -HUP $upid && sleep 3 && kill -9 $upid && unset upid; else continue; fi; done 
