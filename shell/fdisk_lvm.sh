#!/usr/bin/env bash
DISK="$1"
MAX="$2"

FSTAB="/etc/fstab"
DATA="/var/lib/docker"
LOCK="/var/run/fdisk_lvm.lock"

test -d $DATA || mkdir -p $DATA

if [ $# -eq 3 ] ;then
  df -h | grep "$DISK" ; ret=$?
else
  echo "EG: $0 /dev/vdX 300G"
  exit
fi

if [ $ret -eq 0 ] ; then
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

echo """#####################


>>> reboot
>>> wait 10M
>>> echo "./fdisk_lvms.sh /dev/sdaXXX"
"""
fi
