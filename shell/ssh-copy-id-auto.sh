#!/usr/bin/env bash
pass='yourpass'
host=("10.81.41.92" "10.83.18.22" "192.168.1.2.3")

for h in ${host[@]}
do
  timeout 10 ssh $h 'pwd' ; ret=$?
  if [ $ret -eq 0 ]; then
  /usr/bin/expect<<EOF
set force_conservative 0  ;# set to 1 to force conservative mode even if
set timeout -1
spawn timeout 30 ssh-copy-id -i ~/.ssh/id_rsa.pub $h
expect "Are you sure you want to continue connecting (yes/no)? "
send "yes\r"
expect "*?s password:"
send "$pass\r"
expect eof
EOF
  sleep 0.2
  else
    echo "无法链接主机:$h"
  fi
done

