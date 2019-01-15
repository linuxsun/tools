#!/usr/bin/env bash
# install mesos master for centos 7.6
# 此脚本适用于一主多从节点的场景。
# Mesos Master

# 分别在对应节点执行

DNS_ZONE="marathon.mesos"
MESOS_MASTER_NAME="master.${DNS_ZONE}"
MESOS_NODE1_NAME="node1.${DNS_ZONE}"
hostnamectl --static set-hostname $MESOS_MASTER_NAME

MASTER_IP="192.168.90.25"
NODE1_IP="192.168.90.26"
NODE2_IP="192.168.90.27"
NODE3_IP="192.168.90.28"
MESOS_HARBOR="192.168.90.24"
MESOS_STORAGE="192.168.90.30"

QUORUM="1" # master集群数一般为奇数
HOSTS="/etc/hosts"
IPFWS=`mktemp`
IPTABLES="/etc/sysconfig/iptables"
REPOS_MESOSPHERE_IO="""http://repos.mesosphere.io/el/7/no\
arch/RPMS/mesosphere-el-repo-7-1.noarch.rpm"""

HOSTS_IP_NAME=( \
"$MESOS_HARBOR<>harbor.${DNS_ZONE}" \
"$MASTER_IP<>$MESOS_MASTER_NAME" \
"$NODE1_IP<>$MESOS_NODE1_NAME" \
"$NODE2_IP<>node2.${DNS_ZONE}" \
"$NODE3_IP<>node3.${DNS_ZONE}" \
"$MESOS_STORAGE<>storage.${DNS_ZONE}")

for xyz in ${HOSTS_IP_NAME[*]} ; do
    unset ret
    xyz=$(echo $xyz | sed -e 's|<>| |g') 
    grep "$xyz" $HOSTS >/dev/null 2>&1 ; ret=$? 
    if [ $ret -ne 0 ]; then
        tee -a $HOSTS <<- EOF >/dev/null 2>&1
$xyz
EOF
fi
done

rpm -Uvh $REPOS_MESOSPHERE_IO >/dev/null 2>&1
yum -y install mesosphere-zookeeper >/dev/null 2>&1
yum -y install mesos marathon.x86_64 >/dev/null 2>&1

tee /etc/zookeeper/conf/zoo.cfg <<- EOF
maxClientCnxns=50
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/var/lib/zookeeper
clientPort=2181
server.1=$MESOS_MASTER_NAME:2888:3888
EOF

systemctl enable zookeeper.service
systemctl restart zookeeper
systemctl status zookeeper

#/etc/mesos-master/quorum should remain 1 >/dev/null

tee /etc/mesos-master/ip <<- EOF
$MASTER_IP
EOF

tee /etc/mesos-master/hostname <<- EOF
$MESOS_MASTER_NAME
EOF

tee /etc/mesos-master/cluster <<- EOF
charles-cluster.marathon.mesos
EOF

tee /etc/mesos/zk <<- EOF
zk://$MESOS_MASTER_NAME:2181/mesos
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

tee /etc/mesos-acls <<- 'EOF' >/dev/null 2>&1
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

ADD_WITH_SALT=`echo "$RANDOM"pyqZhmdDfBSO4kEH"$RANDOM"` >/dev/null 2>&1
tee /etc/mesos/credentials <<- EOF >/dev/null 2>&1
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
    fi >/dev/null 2>&1
done < $IPFWS
test -f $IPTABLES && \mv -f $IPTABLES $IPTABLES.$RANDOM
iptables-save > $IPTABLES.$RANDOM
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
