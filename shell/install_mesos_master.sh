#!/usr/bin/env bash
# install mesos master for centos 7.2
# 此脚本适用于一主一从的场景。
# Mesos Master

MESOS_MASTER_NAME="mesos-master"
MESOS_NODE_NAME="mesos-node1"
MASTER_IP="192.168.80.100"
NODE_IP="192.168.80.99"
QUORUM="1" # master集群数一般为1、3、5、7。
HOSTS="/etc/hosts"
IPFWS=`mktemp`
IPTABLES="/etc/sysconfig/iptables"

rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
yum -y install mesosphere-zookeeper
yum -y install mesos marathon

hostname $MESOS_MASTER_NAME
tee /etc/hostname <<- EOF
$MESOS_MASTER_NAME
EOF

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
/etc/mesos-master/quorum should remain 1 >/dev/null

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

tee /etc/mesos-acls <<- EOF
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
    ],
    "reserve_resources": [
        {
            "principals": {
                "type": "ANY"
            },
            "roles": {
                "type": "ANY"
            },
            "resources": {
                "type": "ANY"
            }
        }
    ],
    "unreserve_resources": [
        {
            "principals": {
                "type": "ANY"
            },
            "roles": {
                "type": "ANY"
            },
            "reserver_principals": {
                "type": "ANY"
            }
        }
    ],
    "create_volumes": [
        {
            "principals": {
                "type": "ANY"
            },
            "roles": {
                "type": "ANY"
            }
        }
    ],
    "destroy_volumes": [
        {
            "principals": {
                "type": "ANY"
            },
            "roles": {
                "type": "ANY"
            },
            "creator_principals": {
                "type": "ANY"
            }
        }
    ]
}
EOF
echo 'file:///etc/mesos-acls' > /etc/mesos-master/acls

tee $IPFWS <<- EOF
-A INPUT -p tcp -m state --state NEW -m tcp --dport 5050 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 2181 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 53 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 53 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 953 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 953 -j ACCEPT
-A INPUT -s $MASTER_IP -j ACCEPT
-A INPUT -s $NODE_IP -j ACCEPT
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

$(which iptables-save) > $IPTABLES
\rm "$IPFWS"

# Mesos Master
systemctl stop mesos-slave.service
systemctl disable mesos-slave.service
#rm '/etc/systemd/system/multi-user.target.wants/mesos-slave.service'
systemctl restart mesos-master.service
systemctl status mesos-master.service
systemctl restart marathon.service
systemctl status marathon.service
