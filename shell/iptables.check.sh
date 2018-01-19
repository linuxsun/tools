#!/bin/bash

check=$(echo $@ | sed -e 's/-A/-C/g')
#echo $check
/usr/sbin/xtables-multi iptables $check ;ret=$?
if [ "$ret" -eq 0 ]; then
    exit 0;
else
    xtables-multi iptables $@;
fi &>/dev/null
# https://github.com/linuxsun
