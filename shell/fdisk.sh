#!/bin/bash
DISK="$1"
FSTAB="/etc/fstab"
DATA="/data"

test -d $DATA || mkdir $DATA

if [ $# -eq 1 ] ;then
  df -h | grep "$DISK" ; ret=$?
else
  echo "EG: $0 /dev/vdx"
  exit
fi

if [ $ret -eq 1 ] ; then
#echo $ret
#fdisk $DISK
fdisk $DISK << EOF
n
p



wq
EOF

partprobe $DISK
mkfs.ext4 "$DISK"1

mount "$DISK"1 $DATA
grep "$DISK"1 $FSTAB || echo "$DISK"1 $DATA ext4 defaults 0 0 >> $FSTAB


fi
