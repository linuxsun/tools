#!/bin/bash

if [ $# -eq 0 ]; then
  ETH=$(ip addr | grep -o "2: [a-z0-9]......" | cut -d':' -f2 | tr -d ' ')
else
  ETH=$1
fi

ip addr show $ETH > /dev/null 2>&1; ret=$?

if [ $ret -eq 0 ]; then
  set -o nounset -o errexit
  echo $(ip addr show $ETH | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
fi

