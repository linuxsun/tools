#!/usr/bin/env bash

WORKDIR="/etc/coredns"
ETCD_DATA="/data/docker-images/coredns"
COREDNS_NAME="coredns-etcd"
ETCD_VER="elcolio/etcd"
test -d $WORKDIR || mkdir $WORKDIR

if [ -f /usr/bin/docker ]; then
  docker pull $ETCD_VER
  docker ps -a|grep $COREDNS_NAME >/dev/null 2>&1 || docker run -d -p 2379:2379 -p 2380:2380 -p 4001:4001 -p 7001:7001 -v $ETCD_DATA:/data --name $COREDNS_NAME $ETCD_VER:latest
else
  echo "please install docker-ce: install_docker_ce.sh"
  exit 1
fi

tee /etc/rc.d/init.d/coredns <<- 'EOF'
#!/bin/bash
now=$(date +%Y%m%d)
cmd="/etc/coredns/coredns -conf /etc/coredns/Corefile"

start(){
  exec $cmd &
}

stop(){
 ps -ef | grep "$WORKDIR/coredns" | grep -v "grep" |awk '{print $2}'| while read pid 
 do
    C_PID=$(ps --no-heading $pid | wc -l)
    echo "当前PID=$pid"
    if [[ $C_PID == "1" ]]; then
        echo "PID=$pid 准备结束"
        kill -9 $pid
        echo "PID=$pid 已经结束"
    else
        echo "PID=$pid 不存在"
    fi
 done

}

case "$1" in
start)
start
;;
stop)
stop
;;
restart)
stop
start
;;
*)
printf 'Usage: %s {start|stop|restart}\n'"$prog"
exit 1
;;
esac
EOF

tee $WORKDIR/Corefile <<- EOF
. {
    etcd skydns.local {
        path /skydns
        upstream /etc/resolv.conf
    }
    cache 160 skydns.local
    proxy . /etc/resolv.conf
}

dev.com {
    etcd {
        stubzones
        path /skydns
        endpoint http://localhost:2379
        upstream /etc/resolv.conf
    }
    log stdout
    errors stdout
    proxy . /etc/resolv.conf
}

test.com {
    etcd {
        stubzones
        path /skydns
        endpoint http://localhost:2379
        upstream /etc/resolv.conf
    }
    log stdout
    errors stdout
    proxy . /etc/resolv.conf
}

dev.io {
    etcd {
        stubzones
        path /skydns
        endpoint http://localhost:2379
        upstream /etc/resolv.conf
    }
    log stdout
    errors stdout
    proxy . /etc/resolv.conf
}
EOF

test -f $WORKDIR/coredns || cp coredns $WORKDIR/coredns
chmod u+x $WORKDIR/coredns /etc/rc.d/init.d/coredns
systemctl daemon-reload
systemctl restart coredns

# https://github.com/linuxsun/tools.git
#
# remove
# rm /etc/rc.d/init.d/coredns /etc/coredns
# docker stop $COREDNS_NAME && docker rm $COREDNS_NAME
#
