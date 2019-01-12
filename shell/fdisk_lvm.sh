#!/usr/bin/env bash
DISK="$1"
MAX="$2"

FSTAB="/etc/fstab"
DATA="/var/lib/docker"
LOCK="/var/run/fdisk_lvm.lock"
test -d $DATA || mkdir -p $DATA

Help() {
  echo """1. rm $LOCK
2. $0 /dev/[sdbX|vdbX] 200G
3. reboot
4. ./fdisk_lvms.sh"""  
  exit 1
}

if [ $# -eq 2 ] ;then
  #df -h | grep "$DISK" ; ret=$?
  fdisk -l |grep "$DISK" |grep -E '(83  Linux|8e  Linux LVM)' >/dev/null 2>&1 ; ret=$?
else
  Help
fi

fstatus=0
test -f $LOCK && fstatus=0 || fstatus=1
if [ $ret -eq 1 ] && [ $fstatus -eq 1 ] ; then
#echo $ret
#fdisk $DISK

test -f $LOCK || fdisk -c -u $DISK << EOF
n
p


+$MAX


p
t


8e
p
wq
EOF
touch $LOCK
chmod -x $0
echo " Format the disk $DISK successfully, please restart the server"
else
  Help
fi
# https://github.com/linuxsun
