#!/usr/bin/env bash

JSTACK="/application/java/jdk1.8.0_111/bin/jstack"
FREE=$(cat /proc/meminfo |grep 'MemFree:' |awk '{print $2}')
PROJECT_NAME="java"
MIN=524288

if [ $FREE -le $MIN ]; then
    PID=$(/usr/bin/pgrep $PROJECT_NAME)
    echo $PID 
    $JSTACK $PID > pid.$PID.$(date "+%Y-%m-%d-%s").log
fi
