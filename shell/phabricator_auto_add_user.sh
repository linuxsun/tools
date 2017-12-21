#!/bin/bash
# 
# 这个脚本的功能：自动批量添加phabricator帐号。
# users.txt文件,保存了批量导入的用户名列表，格式一定要按规范，如：
# 用户名 中文名 邮箱
# 除了用户名、中文名、邮箱需要写在users.txt文件之外，像密码和输入Y/N操作由脚本自动填充。
# 用户名必须是英文。E-mail地址如果后台"auth.email-domains"开启限制域名，users.txt文件需要调整。
# 可以执行./bin/accountadmin 了解详细的交换步骤。

USER_NAME_LIST="./users.txt"
OUT_PUT="outfile.txt"
USERNAME=""
CNNAME=""

#if [ -s $USER_NAME_LIST ]; then
#  echo "please cleans: $USER_NAME_LIST"
#  exit 1
#else
#tee ./users.txt <<- 'EOF'
#demo011 演示11 demo011@mail.com
#demo012 演示12 demo012@mail.com
#demo013 演示13 demo013@mail.com
#EOF
#fi

randompass() {
    index=0
    str=""
    for i in {a..z}; do arr[index]=$i; index=`expr ${index} + 1`; done
    for i in {A..Z}; do arr[index]=$i; index=`expr ${index} + 1`; done
    for i in {0..9}; do arr[index]=$i; index=`expr ${index} + 1`; done
    for i in {1..8}; do str="$str${arr[$RANDOM%$index]}"; done
    #for i in `eval echo {1..$num}`; do str="$str${arr[$RANDOM%$index]}"; done
    echo $str
}

while read LINE
do
  PASSWORD=$(randompass)
  USERNAME=`echo $LINE| cut -d' ' -f1`
  CNNAME=`echo $LINE| cut -d' ' -f2`
  EMAIL=`echo $LINE| cut -d' ' -f3`
  sleep 2
if [ -n $PASSWORD ]; then
  #echo $USERNAME $CNNAME $PASSWORD $EMAIL
  /usr/bin/expect<<EOF
set force_conservative 0  ;# set to 1 to force conservative mode even if
                          ;# script wasn't run conservatively originally
#if {$force_conservative} {
#        set send_slow {1 .1}
#        proc send {ignore arg} {
#                sleep .1
#                #exp_send -s -- $arg
#                exp_send $arg
#        }
#}

set timeout -1

#./bin/accountadmin << "EOF"
spawn ./bin/accountadmin
expect "*?Enter a username:"
send "$USERNAME\r"
expect "*?Do you want to create a new"
send "Y\r"
expect "*?Enter user real name:"
send "$CNNAME\r"
expect "*?Enter user email address:"
send "$USERNAME@mail.com\r"
expect "*?Enter a password for this user"
send "$PASSWORD\r"
expect "*?Is this user a bot"
send "N\r"
expect "*?Should this user be an administrator"
send "N\r"
expect "*?Save these changes"
send "Y\r"
expect eof
EOF

fi
  echo "$(date) $USERNAME $CNNAME $PASSWORD $EMAIL" >> $OUT_PUT
done < $USER_NAME_LIST
