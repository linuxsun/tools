#!/bin/bash

#DOCKER_VERSION="1.13.1"
#DOCKER_SELINUX_VERSION="1.13.1"

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
    yum install -y yum-utils
    yum-config-manager \
    --add-repo \
    https://docs.docker.com/v1.13/engine/installation/linux/repo_files/centos/docker.repo
    
    # yum-config-manager --enable docker-testing
    yum-config-manager --disable docker-testing
    yum makecache fast
    yum list docker-engine.x86_64  --showduplicates |sort -r
    #yum -y install docker-engine-$DOCKER_VERSION docker-engine-selinux-$DOCKER_SELINUX_VERSION
    yum -y install docker-engine docker-engine-selinux

    systemctl enable docker.service
    systemctl restart docker.service
}

Config() {
DAEMON_JSON="/etc/docker/daemon.json"
RDOM=$(date "+%Y%m%d%H%M%S")
test -f $DAEMON_JSON && cp $DAEMON_JSON $DAEMON_JSON.bak.$RDOM
sudo tee "$DAEMON_JSON" <<-'EOF'
{
  "insecure-registries" : [ "registry.docker-cn.com","harbor.dev.com" ],
  "registry-mirrors": [ "https://registry.docker-cn.com","http://harbor.dev.com" ]
}
EOF
}

Help() {
echo """1) uname -r => '3.10.0-327.10.1.el7.x86_64'
2) mkfs -t xfs -n ftype=1 /dev/sdc1
3) sudo yum upgrade --assumeyes --tolerant Or  sudo yum update --assumeyes 
4) sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
   overlay
   EOF
5) reboot
6) lsmod | grep overlay
   overlay """

echo "7) $0 [remove|install|config]"
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
  *)
    Help
  ;;
esac
fi

# https://dcos.io/docs/1.10/installing/custom/system-requirements/install-docker-centos/
# https://github.com/craimbert/mesos-tutorial
# https://docs.docker.com/v1.13/engine/installation/linux/centos/
# https://github.com/linuxsun
