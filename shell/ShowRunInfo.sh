#!/usr/bin/env bash
AppsType="java"
#RunUser=`id -u -n`
AppsName="$1"
#ShowVars="$2"
RunInfo=(0 0 0 0 0 0 0 0 0 0 0)
ppid='NULL'

ShowHelp() {
  HelpInfo="$0 AppsName [pid|cpu|mem|rss]"
  echo $HelpInfo
}

ShowPid () {
  unset RunInfo
  RunInfo=(`ps -aux|grep $AppsType|grep "$AppsName"|grep -v \
grep|sed -n '1p'|awk '{print $2,$3,$4,$6}'`)
  [ -z "$RunInfo" ] && ppid='NULL' || ppid=${RunInfo[0]} 
  [ -z "$RunInfo" ] && RunInfo=(0 0 0 0 0 0 0 0 0 0 0)
}

ShowRunInfoVars () {
  ShowPid
  #for vars in PIDD CPUU MEMM RSSS; do unset $vars; done ; unset vars
  PIDD=${RunInfo[0]}
  CPUU=${RunInfo[1]}
  MEMM=${RunInfo[2]}
  RSSS=${RunInfo[3]}
}

if [ $# -ne 2 ];then
  unset RunInfo
  ShowHelp
  exit 1
else
  unset RunInfo
  for vars in PIDD CPUU MEMM RSSS; do unset $vars; done ; unset vars
  ShowPid
  ShowRunInfoVars
  #echo "$PIDD $CPUU $MEMM $RSSS"
  if [ "$2" = "pid" ];then
    echo $PIDD
  elif [ "$2" = "cpu" ];then
    echo $CPUU
  elif [ "$2" = "mem" ];then
    echo $MEMM
  elif [ "$2" = "rss" ];then
    echo $RSSS
  else
    unset RunInfo
    ShowHelp
    exit 1
  fi
fi

unset vars RunInfo PIDD CPUU MEMM RSSS AppsType RunUser AppsName ShowVars RunInfoInit ppid

#ps -aux
#1  USER
#2  PID
#3  %CPU
#4  %MEM
#5  VSZ
#6  RSS
#7  TTY
#8  STAT
#9  START
#10 TIME
#11 COMMAND

