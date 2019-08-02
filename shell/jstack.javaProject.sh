#!/usr/bin/env bash

which jstack >/dev/null && : || exit 0
Count=0 ; Break=5 ; waitTime=10 ; CpuUseAlarm=10
maxSleepCount=1000 ; minFreeMem=1024
projectName='java' ; Site="${projectName}A"
# projectName=("etermconfig" | "tomcat" | "server-rpc-project.jar" \
# | "..." | "All JAVA projects")

if [ $# -eq 1 ];then
    projectName="$1" ; Site="${projectName}A"
else
    projectName="${projectName}"
fi

Help () {
    echo "$0 [tomcat|server-rpc-project.jar|...|All_Java_Projects]"
}

Dump () {
    whoAmi=`whoami`
    userPid=(`ps -ef |grep java|grep "$projectName" |grep -Ev \
"(grep|$0)" |awk '{print $1,$2}'`)
    #runPid=${userPid##*\ } ; runUser=${userPid%%\ *}
    if [ ${#userPid[@]} -ge 2 ]; then
        runUser="${userPid[0]}"
        runPid=${userPid[1]}
        if [ $runPid -le 1 ] || [ -z "$runUser" ]; then
            echo "runPid:<=1,runUser:null"
            exit 0
        fi
    else
       echo "userPid:null"
       Help
       exit 0
    fi
    if [ "$whoAmi" = "$runUser" ] && [ -n $runPid ] ; then
        Time=$(date +%s) ; Dir=$0 ; Dir=`dirname $Dir`
        jstack $runPid >> $Dir/${Site}.pid.${runPid}.log ; ret=$?
        if [ $ret -ne 0 ];then
            break 
        fi
        echo "jstack $runPid >> $Dir/${Site}.pid.${runPid}.log"
        echo ">>>$Time" >> $Dir/${Site}.pid.${runPid}.log
   else
      echo "当前用户${whoAmi},并非运行该java项目${projectName}的用户."
      exit 0
   fi
}

Check () {
    RunSleepCount=(`top -b -n1 |head -10|grep -E '(sleeping|running)'\
 | awk '{print $4,$6}'`)
    if [ ${#RunSleepCount[@]} -eq 2 ]; then
        running=${RunSleepCount[0]}
        sleeping=${RunSleepCount[1]}
        sleepCount=$(( running + sleeping ))
    else
        sleepCount=0
    fi
    freeMem=$(free -m|grep Mem|awk '{print $4}')
}

CheckCpu() {
    #cpuUseCount=0
    #uptime1m=$(printf '%.f' `uptime | awk '{print $10}'|tr -d ','`)
    #uptime1m=$(( $(printf '%.f' `uptime | awk '{print $10}'|tr -d ','`) * 2 ))
    uptime1m=$(printf '%.f' `uptime | awk '{print $10}'|tr -d ','`)
    cpuCoreNum=$(( $(cat /proc/cpuinfo |grep processor|wc -l) * 2 ))
    #cpuCoreNum=$(cat /proc/cpuinfo |grep processor|wc -l)
    cpuCore100=$(( `cat /proc/cpuinfo |grep processor|wc -l` * 100 ))
    cpuUsSy=(`printf '%.f %.f' $(top -b -n1 |head -10|sed -n '3p' | awk '{print $1,$3}'|tr -d '%Cpu(s):' |grep  '[0-9]')`)
    if [ $uptime1m -gt $cpuCoreNum ];then
      cpuUseCount=$(( cpuUseCount += 1 ))
    elif [ ${cpuUsSy[0]} -gt 90 ] || [ ${cpuUsSy[1]} -gt 90 ] ;then
      cpuUseCount=$(( cpuUseCount += 1 ))
    fi
    echo "uptime1m:$uptime1m, cpuCoreNum:$cpuCoreNum, cpuCore100:$cpuCore100, cpuUsSy:${cpuUsSy[@]}"
    echo "cpuUseCount:$cpuUseCount"
    return $cpuUseCount
}

outputDict () {
echo -e "{"
echo -e "    \"Count\":$Count,"
echo -e "    \"Break\":$Break,"
echo -e "    \"sleepCount\":$sleepCount,"
echo -e "    \"maxSleepCount\":$maxSleepCount,"
echo -e "    \"freeMem\":$freeMem,"
echo -e "    \"minFreeMem\":$minFreeMem"
echo -e "}"
}

Main () {
  while [ $Count -le $Break ]
  do
    Check
    if [ -n "$sleepCount" -a $sleepCount -ge $maxSleepCount ]\
 || [ -n "$freeMem" -a $freeMem -le $minFreeMem ]
    then
        Dump
        Count=$(( Count += 1 ))
    fi 
  outputDict
  sleep $waitTime
  done
}

MainCpu () {
    cpuUseCount=0
    while :
    #while [ $Count -le $Break ]
    do
      CheckCpu
      #echo "<>$cpuUseCount<>"
      if [ $cpuUseCount -ge $CpuUseAlarm ]; then
        Dump
        #cpuUseCount=0
        echo "cpuUseCount:$cpuUseCount"
      fi
      if [ $cpuUseCount -ge $(( CpuUseAlarm * 2 )) ];then
        exit 1
      fi
      sleep $waitTime
    done
}
MainCpu&
Main&

# chmod +x /etc/rc.d/rc.local
# echo "su - admin -c 'nohup /home/admin/jstack.javaProject.sh \
# >/dev/null 2>&1 &'" >> /etc/rc.local

