#!/usr/bin/env bash
# install mesos node for centos 7.2
# 此脚本适用于一主一从的场景。
# Mesos Node

MESOS_MASTER_NAME="mesos-master"
MESOS_NODE_NAME="mesos-node1"
MASTER_IP="192.168.80.100"
NODE_IP="192.168.80.99"
HOSTS="/etc/hosts"
IPFWS=`mktemp`
IPTABLES="/etc/sysconfig/iptables"

rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
yum -y install mesos telnet

hostname $MESOS_NODE_NAME
tee /etc/hostname <<- EOF
$MESOS_NODE_NAME
EOF

grep "$MASTER_IP" $HOSTS ; ret=$?
if [ $ret -eq 1 ];then
    echo "$MASTER_IP $MESOS_MASTER_NAME" >> $HOSTS
    echo "$NODE_IP $MESOS_NODE_NAME" >> $HOSTS
fi

tee /etc/mesos-slave/ip <<- EOF
$NODE_IP
EOF

tee /etc/mesos/zk <<- EOF
zk://$MASTER_IP:2181/mesos
EOF

tee /etc/mesos-slave/hostname <<- EOF
$NODE_IP
EOF

tee /etc/mesos-slave/executor_registration_timeout <<- EOF
10mins
EOF

tee /etc/mesos-slave/containerizers <<- 'EOF'
docker,mesos
EOF

tee $IPFWS <<- EOF
-A INPUT -p tcp -m state --state NEW -m tcp --dport 5051 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
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

# Mesos Node
systemctl stop mesos-master.service
systemctl disable mesos-master.service
#rm '/etc/systemd/system/multi-user.target.wants/mesos-master.service'

systemctl restart mesos-slave.service
systemctl enable mesos-slave.service
systemctl status mesos-slave.service
ps -aux | grep mesos-slave

# https://stackoverflow.com/questions/28457891/why-marathon-does-not-terminate-jobs-after-the-quorum-is-lost
# https://issues.apache.org/jira/browse/MESOS-2934

# https://github.com/linuxsun
