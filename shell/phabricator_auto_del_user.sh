#!/bin/bash
USER_NAME_LIST="./users.txt"

#if [ -s $USER_NAME_LIST ]; then
#  echo "please cleans: $USER_NAME_LIST"
#  exit 1
#else
#  tee ./users.txt <<- 'EOF'
#demo011 演示11 demo011@mail.com
#demo012 演示12 demo012@mail.com
#demo013 演示13 demo013@mail.com
#EOF
#fi

while read LINE
do
if [[ -f $USER_NAME_LIST ]] && [[ -n $LINE ]]; then
sleep 3
USERNAME=`echo $LINE| cut -d' ' -f1`

/usr/bin/expect<<EOF
    set force_conservative 0  ;# set to 1 to force conservative mode even if
                              ;# script wasn't run conservatively originally
    set timeout -1
spawn ./bin/remove destroy @$USERNAME
expect "*?Are you absolutely certain you want to destroy this object"
send "Y\r"
expect eof
EOF
fi
done < $USER_NAME_LIST
# https://github.com/linuxsun
