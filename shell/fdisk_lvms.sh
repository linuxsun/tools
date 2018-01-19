#!/usr/bin/env bash

DEV="$1"
DATA="/var/lib/docker"
LOCK="/var/run/fdisk_lvm.lock"
FSTAB="/etc/fstab"

if [[ $# -eq 1 ]] && [[ -f $LOCK ]]; then

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

  chmod -x $0

else
  echo "$0 /dev/sdaX"

fi

# https://github.com/linuxsun
