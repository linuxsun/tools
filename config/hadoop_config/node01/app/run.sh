#!/bin/env bash

PID_FILE="/var/run/hadoop_shell.pid"

HELP() {
  echo "$0 start|stop"
}

if [ $# -eq 0 ];then
  HELP
  exit 1
else

case $1 in
  start)
    #node01
    /app/hadoop-2.7.1/sbin/mr-jobhistory-daemon.sh start historyserver
    sleep 2
    /app/hadoop-2.7.1/sbin/start-all.sh
    #/app/hadoop-2.7.1/sbin/start-dfs.sh
    #/app/hadoop-2.7.1/sbin/start-yarn.sh

    sleep 5
    #node01-node04
    #/app/zookeeper-3.4.6/bin/zkServer.sh start

    #node01
    /app/hbase-1.3.1/bin/start-hbase.sh

    #node01
    #nohup hive --service hwi &
    cd /app/apache-hive-2.1.1-bin ; nohup bin/hive --service hiveserver2 &
    if [ $? -eq 0 ];then
      echo $! > $PID_FILE.$$ ; \mv $PID_FILE.$$ $PID_FILE
      ps -f -p `cat $PID_FILE`
    fi
    ;;

  stop)
    /app/hadoop-2.7.1/sbin/mr-jobhistory-daemon.sh stop historyserver
    sleep 2
    /app/hadoop-2.7.1/sbin/stop-all.sh
    sleep 5
    /app/hbase-1.3.1/bin/stop-hbase.sh
    test -f $PID_FILE && kill -9 `cat $PID_FILE`
    ;;
  *)
    HELP   
    ;;
esac
fi
