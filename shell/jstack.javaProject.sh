#!/usr/bin/env bash

which jstack >/dev/null && : || exit 0

# etermconfig=[ etermconfig | tomcat | server-rpc-project.jar | ... | All JAVA projects ]
projectName='etermconfig' ; Site="${projectName}2"
Count=0 ; Break=5 ; waitTime=10
maxSleepCount=1000 ; minFreeMem=1024
#maxSleepCount=10 ; minFreeMem=1024

Dump () {
    whoAmi=`whoami`
    userPid=$(ps -ef |grep java|grep "$projectName"|awk '{print $1,$2}')
    runPid=${userPid##*\ }
    runUser=${userPid%%\ *}
    if [ "$whoAmi" = "$runUser" ]; then
      Time=$(date +%s) ; Dir=$0 ; Dir=`dirname $Dir`
      if [ $Dir = '.' ]; then
          Dir="./" 
      fi
      if [ -n "$runPid" ]; then
          jstack $runPid >> $Dir/${Site}.pid.$runPid.log
          echo ">>>$Time" >> $Dir/${Site}.pid.$runPid.log
      fi
   else
      echo "当前用户${whoAmi},并非运行该java项目${Site}的用户."
      #exit 0
   fi
}

Check () {
    sleepCount=$(top -b -n1 |head -10|grep sleeping| awk '{print $6}')
    freeMem=$(free -m|grep Mem|awk '{print $4}')
}

Main () {
  #self=$0
  #self=${self##*/}
  while [ $Count -le $Break ]
  do
    Check
    if [ -n "$sleepCount" -a $sleepCount -ge $maxSleepCount ]\
 || [ -n "$freeMem" -a $freeMem -le $minFreeMem ]
    then
        Dump
        Count=$(( Count += 1 ))
    fi 
  echo ">>> Count:$Count Break:$Break sleepCount:$sleepCount \
maxSleepCount:$maxSleepCount freeMem:$freeMem minFreeMem:$minFreeMem"
  sleep $waitTime
  done
}

Main


