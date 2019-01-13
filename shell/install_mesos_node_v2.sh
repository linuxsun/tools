#!/usr/bin/env bash
# install mesos node for centos 7.6
# 此脚本适用于一主多从的场景。
# Mesos Node{1,2,3}

MESOS_MASTER_NAME="mesos-master" # 
MESOS_NODE_NAME="mesos-node1"    # your node name: mesos-node{1,2,3}
MASTER_IP="192.168.90.25"
NODE_IP="192.168.90.26"          # your ip add: 192.168.90.{26,27,28}
NODE1_IP="$NODE_IP"
NODE2_IP="192.168.90.27"
NODE3_IP="192.168.90.28"
MESOS_HARBOR="192.168.90.24"
MESOS_STORAGE="192.168.90.30"

HOSTS="/etc/hosts"
IPFWS=`mktemp`
IPTABLES='/etc/sysconfig/iptables'
IPTABLES_RULES='/usr/local/sbin/iptables.mesos.rule.sh'

rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm >/dev/null 2>&1 
yum -y install mesos >/dev/null 2>&1

#hostname $MESOS_NODE_NAME
#tee /etc/hostname <<- EOF
#$MESOS_NODE_NAME
#EOF
hostnamectl set-hostname $MESOS_NODE_NAME

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
test -f /usr/sbin/xtables-multi || exit 1
while read LINE
do
    check=$(echo $LINE | sed -e 's/-A/-C/g')
    /usr/sbin/xtables-multi iptables $check ;ret=$?
    if [ $ret -eq 0 ]; then
        continue
        #exit 0;
    else
        xtables-multi iptables $LINE;
    fi
done < $IPFWS

test -f $IPTABLES_RULES && cat /dev/null > $IPTABLES_RULES
sed -i 's/-A INPUT/iptables -I INPUT/g' $IPFWS  && \mv -f $IPFWS $IPTABLES_RULES
sed -i '1 i #!/usr/bin/env bash' $IPTABLES_RULES
test -f $IPTABLES_RULES && chmod 754 $IPTABLES_RULES
`$IPTABLES_RULES`

grep "$IPTABLES_RULES" /etc/rc.local > /dev/null 2>&1 ; ret=$? 
if [ $ret -eq 1 ]; then
tee -a /etc/rc.local <<- EOF  >/dev/null 2>&1 
$IPTABLES_RULES >/dev/null 2>&1 &
EOF
fi

# Mesos Node
systemctl stop mesos-master.service
systemctl disable mesos-master.service
#rm '/etc/systemd/system/multi-user.target.wants/mesos-master.service'

systemctl restart mesos-slave.service
systemctl enable mesos-slave.service
systemctl status mesos-slave.service
ps -aux | grep mesos-slave

# docker启动会自动添加iptables rules，请不要让iptables开机自动加载默认的rules,
# 默认rules不带docker相关的链表
test -f $IPTABLES && \cp $IPTABLES ${IPTABLES}.$RANDOM && rm $IPTABLES
$(which iptables-save) > ${IPTABLES}.$RANDOM
/usr/bin/systemctl restart iptables.service
/usr/bin/systemctl restart ip6tables

# https://stackoverflow.com/questions/28457891/why-marathon-does-not-terminate-jobs-after-the-quorum-is-lost
# https://issues.apache.org/jira/browse/MESOS-2934

# https://github.com/linuxsun
