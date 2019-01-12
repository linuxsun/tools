#!/bin/env bash

SysType() {
    Kernel=`uname -r |cut -d'.' -f1-2`
    Version=`uname -r |cut -d'.' -f6`
}
SysType

Remove() {
    yum -y autoremove docker docker-common container-selinux
    yum -y autoremove docker-selinux
    yum -y autoremove docker-engine docker-engine-selinux
}

Install() {
    yum install -y yum-utils \
    device-mapper-persistent-data lvm2

    yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    
    #yum-config-manager --enable docker-ce-edge
    # yum-config-manager --enable docker-ce-test
    yum-config-manager --disable docker-ce-edge

    yum makecache fast
    yum install -y docker-ce
    yum list docker-ce --showduplicates | sort -r
    
    systemctl enable docker.service
    systemctl restart docker.service
}

BRIDGE_NF_CALL_IPTABLES() {
#"""
#docker info
#......
#WARNING: bridge-nf-call-iptables is disabled
#WARNING: bridge-nf-call-ip6tables is disabled
#"""
    SYSCTL='/etc/sysctl.conf'
    SYSCTL_DOCKER_BRIDGE_NF_CALL=('net.bridge.bridge-nf-call-ip6tables = 1' \
'net.bridge.bridge-nf-call-iptables = 1' '#net.bridge.bridge-nf-call-arptables = 1')

    for i in "${SYSCTL_DOCKER_BRIDGE_NF_CALL[@]}" ; do
        grep "$i" $SYSCTL >/dev/null 2>&1 ; ret=$?
        if [ $ret -ne 0 ]; then
tee -a "$SYSCTL" <<- EOF
$i
EOF
        fi
    done
}

Config() {
DAEMON_JSON="/etc/docker/daemon.json"
RDOM=$(date "+%Y%m%d%H%M%S")
test -f $DAEMON_JSON && cp $DAEMON_JSON $DAEMON_JSON.bak.$RDOM

sudo tee "$DAEMON_JSON" <<- 'EOF'
{
  "insecure-registries" : [ "registry.docker-cn.com","reg.dev.com","harbor.dev.com" ],
  "registry-mirrors": [ "https://registry.docker-cn.com","https://reg.dev.com","http://harbor.dev.com" ]
}
EOF

}

Help() {

echo """
1) uname -r => '3.10.0-327.10.1.el7.x86_64'

2) yum upgrade --assumeyes --tolerant Or  sudo yum update --assumeyes 

3) tee /etc/modules-load.d/overlay.conf <<-'EOF' #可选项,因为默认存储驱动是overlay2
overlay
EOF

4) reboot

5) lsmod | grep overlay #可选项
overlay

6) "$0 '[remove|install|config|bridge-nf-call-iptables]'"
"""
}

if [[ $? = 1 ]] && [[ (( "$Kernel" < "3.10" )) ]] &&  [[ "$Version" != "el7" ]]
then
  Help
  exit 1
else
case $1 in
  remove)
    Remove  
  ;;
  install)
    Install
  ;;
  config)
    Config
  ;;
  bridge-nf-call-iptables)
     BRIDGE_NF_CALL_IPTABLES
  ;;
  *)
    Help
  ;;
esac
fi

# https://docs.docker.com/engine/installation/linux/docker-ce/centos/#upgrade-docker-ce-1
# https://dcos.io/docs/1.10/installing/custom/system-requirements/install-docker-centos/
# https://github.com/craimbert/mesos-tutorial
# https://docs.docker.com/v1.13/engine/installation/linux/centos/
# https://github.com/linuxsun
