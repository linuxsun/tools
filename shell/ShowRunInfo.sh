#!/usr/bin/env bash
JAVA="java"
RunUser="root"
ProjName="$1"
ShowVars="$2"
RunInfoInit="0 0 0 0 0 0 0 0 0 0 0"

ShowHelp() {
  HelpInfo="$0 ProjectName [pid|cpu|mem|rss]"
  echo $HelpInfo
}

ShowPid () {
  unset ppid
  ppid=`ps -ax|grep $JAVA|grep "$ProjName"|grep -v \
grep|awk '{print $1}'`
  ppid=${ppid:-"null"}
  #ppid=`echo ${ppid%\ *}`
  ppid=`echo $ppid |awk '{print $1}'`
}

ShowRunInfoVars () {
  for vars in PIDD CPUU MEMM RSSS; do unset $vars;\
done ; unset vars
  #PIDD=`echo ${RunInfo%$RunUser*}`
  PIDD=`echo $RunInfo|awk '{print $1}'`
  CPUU=`echo $RunInfo|awk '{print $2}'`
  MEMM=`echo $RunInfo|awk '{print $3}'`
  RSSS=`echo $RunInfo|awk '{print $4}'`
}

ShowInfo () {
  unset RunInfo
  ShowPid
  #echo $ppid
  if [ "$ppid" = 'null' ];then
    RunInfo="$RunInfoInit"
    ShowRunInfoVars
  else
    RunInfo=`ps -aux|grep $JAVA|grep "$ProjName"|grep -v \
grep|sed -n '1p'|awk '{print $2,$3,$4,$6}'`
    ShowRunInfoVars
  fi
}

if [ $# -ne 2 ];then
  ShowHelp
  exit 1
else
  ShowInfo
  #echo $RunInfo
  if [ "$2" = "pid" ];then
    echo $PIDD
  elif [ "$2" = "cpu" ];then
    echo $CPUU
  elif [ "$2" = "mem" ];then
    echo $MEMM
  elif [ "$2" = "rss" ];then
    echo $RSSS
  else
    ShowHelp
    exit 1
  fi
fi

for vars in RunInfo PIDD CPUU MEMM RSSS \
JAVA RunUser ProjName ShowVars RunInfoInit ppid
do
  unset $vars
done
unset vars

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
