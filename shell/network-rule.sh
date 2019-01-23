#!/usr/bin/env bash
NUM=($@)

ENABLE () {
if [ ${#NUM[@]} -eq 1 ]; then
    echo "wondershaper eth0 200 200"
    wondershaper eth0 200 200
else
    if [ ${#NUM[@]} -ne 4 ]; then
        exit 1
    else
        INT=${NUM[1]}       #网卡名称
        INPUT=${NUM[2]}     #上行速度 Kb/s
        OUTPUT=${NUM[3]}    #下行速度 Kb/s
        echo "wondershaper $INT $INPUT $OUTPUT"
        wondershaper $INT $INPUT $OUTPUT
    fi
fi
}

DISABLE () {
    echo "wondershaper clear eth0"
    wondershaper clear eth0
}

case $1 in 
    enable)
      ENABLE
;;

    disable)
      DISABLE
;;

*)
  echo "$0 [enable|disable] eth0 400 400"
;;
esac

# CentOS-7.x-x64
# yum install epel-release -y
# yum install wondershaper -y
# 限速: wondershaper eth0 4000 400
# 取消限速: wondershaper clear eth0
# 20190123

