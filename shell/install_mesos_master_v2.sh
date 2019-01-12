#!/usr/bin/env bash
# install mesos master for centos 7.2
# 此脚本适用于一主一从的场景。
# Mesos Master

MESOS_MASTER_NAME="mesos-master"
MESOS_NODE_NAME="mesos-node1"
MASTER_IP="192.168.90.25"
NODE_IP="192.168.90.26"
NODE1_IP="$NODE_IP"
NODE2_IP="192.168.90.27"
NODE3_IP="192.168.90.28"
MESOS_HARBOR="192.168.90.24"
MESOS_STORAGE="192.168.90.30"
QUORUM="1" # master集群数一般为1、3、5、7。
HOSTS="/etc/hosts"
IPFWS=`mktemp`
IPTABLES="/etc/sysconfig/iptables"

rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm >/dev/null 2>&1
yum -y install mesosphere-zookeeper >/dev/null 2>&1
yum -y install mesos marathon.x86_64 >/dev/null 2>&1

#hostname $MESOS_MASTER_NAME
#tee /etc/hostname <<- EOF
#$MESOS_MASTER_NAME
#EOF
hostnamectl --static set-hostname $MESOS_MASTER_NAME

unset ret
grep "$MASTER_IP" $HOSTS ; ret=$?

if [ $ret -eq 1 ];then
    echo "$MASTER_IP $MESOS_MASTER_NAME" >> $HOSTS
    echo "$NODE_IP $MESOS_NODE_NAME" >> $HOSTS
fi

tee /etc/zookeeper/conf/zoo.cfg <<- EOF
maxClientCnxns=50
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/var/lib/zookeeper
clientPort=2181
server.1=$MASTER_IP:2888:3888
EOF

systemctl enable zookeeper.service
systemctl restart zookeeper
systemctl status zookeeper

#/etc/mesos-master/quorum should remain 1 >/dev/null

tee /etc/mesos-master/ip <<- EOF
$MASTER_IP
EOF

tee /etc/mesos-master/hostname <<- EOF
$MASTER_IP
EOF

tee /etc/mesos-master/cluster <<- EOF
charles-cluster
EOF

tee /etc/mesos/zk <<- EOF
zk://$MASTER_IP:2181/mesos
EOF

tee /etc/mesos-master/quorum <<- EOF
$QUORUM
EOF

tee /etc/default/mesos-master <<- EOF
PORT=5050
ZK=`cat /etc/mesos/zk`
MESOS_QUORUM=`cat /etc/mesos-master/quorum`
EOF

tee /etc/default/mesos-slave <<- EOF
MASTER=`cat /etc/mesos/zk`
EOF

tee /etc/mesos-acls <<- 'EOF'  >/dev/null 2>&1
{
    "run_tasks": [
    {
      "principals": {
        "type": "ANY"
      },
      "users": {
        "type": "ANY"
      }
    }
  ],
  "register_frameworks": [
    {
      "principals": {
        "type": "ANY"
      },
      "roles": {
        "type": "ANY"
      }
    }
  ]
}
EOF
echo 'file:///etc/mesos-acls' > /etc/mesos-master/acls

ADD_WITH_SALT=`echo "$RANDOM"pyqZhmdDfBSO4kEH"$RANDOM"`  >/dev/null 2>&1
tee /etc/mesos/credentials <<- EOF  >/dev/null 2>&1
{
    "credentials": [
        {
        "principal": "marathon",
        "secret": "$ADD_WITH_SALT"
        }
    ]
}
EOF

tee /etc/mesos/marathon.secret <<- EOF >/dev/null 2>&1
$ADD_WITH_SALT
EOF

tee /etc/mesos-master/credentials <<- EOF
file:///etc/mesos/credentials
EOF

test -d /etc/marathon/conf || mkdir -p /etc/marathon/conf
echo 'marathon' > /etc/marathon/conf/mesos_authentication_principal
echo 'marathon' > /etc/marathon/conf/mesos_role

tee $IPFWS <<- EOF >/dev/null 2>&1
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 5050 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 2181 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 53 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 53 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 953 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 953 -j ACCEPT
-A INPUT -s $MASTER_IP -j ACCEPT
-A INPUT -s $NODE_IP -j ACCEPT
-A INPUT -s $NODE1_IP -j ACCEPT
-A INPUT -s $NODE2_IP -j ACCEPT
-A INPUT -s $NODE3_IP -j ACCEPT
-A INPUT -s $MESOS_HARBOR -j ACCEPT
-A INPUT -s $MESOS_STORAGE -j ACCEPT
EOF

unset ret
while read LINE
do
    check=$(echo $LINE | sed -e 's/-A/-C/g')
    /usr/sbin/xtables-multi iptables $check ;ret=$?

    if [ "$ret" -eq 0 ]; then
        continue
        #exit 0;
    else
        xtables-multi iptables $LINE;
    fi &>/dev/null

done < $IPFWS
cp $IPTABLES $IPTABLES.$RANDOM
iptables-save > $IPTABLES
\rm "$IPFWS"

# Mesos Master
systemctl stop mesos-slave.service
systemctl disable mesos-slave.service
#rm '/etc/systemd/system/multi-user.target.wants/mesos-slave.service'
systemctl restart mesos-master.service
systemctl status mesos-master.service
systemctl restart marathon.service
systemctl status marathon.service

# https://github.com/linuxsun
# https://coolex.info/blog/523.html
# https://yuerblog.cc/2017/02/10/marathon-persistent-volumes/
# https://mesosphere.github.io/marathon/docs/framework-authentication.html
# http://mesos.apache.org/documentation/latest/authentication/
# 


