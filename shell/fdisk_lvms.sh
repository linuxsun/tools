#!/usr/bin/env bash

DEV="$1"
DATA="/var/lib/docker"
LOCK="/var/run/fdisk_lvm.lock"
FSTAB="/etc/fstab"
fstatus=0
test -f $LOCK && fstatus=0 || fstatus=1

if [[ $# -eq 1 ]] && [[ $fstatus -eq 1 ]]; then

  pvcreate $DEV
  vgcreate docker $DEV
  lvcreate --name docker -l 100%FREE docker
  lvmdiskscan
  pvdisplay
  lvdisplay

  mkfs -t xfs -n ftype=1 /dev/docker/docker
  xfs_info $DATA |grep 'ftype=1'
  test -d $DATA || mkdir -p $DATA
  mount /dev/mapper/docker-docker $DATA
  grep '/dev/mapper/docker-docker' $FSTAB || echo "/dev/mapper/docker-docker /var/lib/docker   xfs defaults 0 0" >> $FSTAB
  if [ $0 ]; then
    touch $LOCK
  fi
  chmod -x $0
else
  echo """1. Delete $LOCK
2. $0 /dev/sdaX"""

fi

# https://github.com/linuxsun
