#!/bin/bash

PID_FILE="pid"
JAVA=$(which java)

HELP() {
    echo "$0 start|stop"
}

FIND_JAR_PATH() {
    JAR_HERE=$(find . -name "$SVN_PROJECT_NAME"-*-SNAPSHOT.jar |sort |tail -n -1)
}
#FIND_JAR_PATH

CHECK_PID() {
    sleep 1
    test -f $PID_FILE || touch $PID_FILE
    PID=`cat $PID_FILE`
    ps -p $PID > /dev/null 2>&1 ; ret=$?
}

ON_APPS() {
    FIND_JAR_PATH
    CHECK_PID
    if [[ $ret -eq 1 ]] && [[ $JAR_HERE ]] ;then
      #nohup $JAVA -jar $JAR_HERE > /dev/null 2>&1 & 
      $JAVA -jar $JAR_HERE
      if [ $? -eq 0 ]; then
        echo $! > $PID_FILE.$$ ; \mv $PID_FILE.$$ $PID_FILE
        echo "Done"
        ps -f -p `cat $PID_FILE`
      fi
    else
      if [ $ret -eq 0 ]; then
        echo "online"
        ps -f -p $PID
      else
        echo "cant find -name  *.jar"
      fi
    fi
}

OFF_APPS() {
    CHECK_PID
    if [ $ret -eq 0 ]; then
      echo "kill PID: $PID"
      kill -9 $PID
      \rm $PID_FILE
    else
      echo "offline"
    fi 
}

#have_tty=0
#if [ "`tty`" != "not a tty" ]; then
#    have_tty=1
#fi

case $1 in
  start)
    #if [ $have_tty -eq 1 -a $# -eq 2 ]
    if [ $# -eq 1 ]
    then
      ON_APPS
    else
      HELP
    fi
  ;;
  stop)
    #if [ $have_tty -eq 1 -a $# -eq 1 ]
    if [  $# -eq 1 ]
    then
      OFF_APPS
    else
      HELP
    fi
  ;;
  *)
    HELP
  ;;
esac


