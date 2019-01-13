#!/usr/bin/env bash

if [[ "$(whoami)" != "root" ]]; then
  
    echo "please run this script as root ." >&2
    exit 1
fi

LOCK_FILE="/var/run/sys_init.lock"
SSH_PORT=22

yum_update(){
    #yum -y install wget
    #cd /etc/yum.repos.d/ && mkdir bak && mv ./*.repo bak
    #wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    #wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    yum clean all && yum makecache 2>&1 >/dev/null
    yum -y install net-tools lrzsz telnet gcc gcc-c++ make cmake libxml2-devel \
openssl-devel curl curl-devel unzip sudo ntp libaio-devel wget vim ncurses-devel \
autoconf automake zlib-devel python-devel 2>&1 >/dev/null
}

zone_time(){
    TIME_SERVER="asia.pool.ntp.org"
    CRON_ROOT="/var/spool/cron/root"
    ECODE_I18N="/etc/sysconfig/i18n"
    /bin/ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    #printf 'ZONE="Asia/Shanghai"\nUTC=false\nARC=false' > /etc/sysconfig/clock
    /usr/sbin/ntpdate $TIME_SERVER
    /bin/grep "$TIME_SERVER" $CRON_ROOT || /bin/echo "* */5 * * * /usr/sbin/ntpdate $TIME_SERVER > /dev/null 2>&1" >> $CRON_ROOT
    /bin/chmod 600 $CRON_ROOT
    /bin/echo 'LANG="en_US.UTF-8"' > $ECODE_I18N
    source $ECODE_I18N
} 

ulimit_config(){
unset ret
LIMITS="/etc/security/limits.conf"
MEMTOTAL=`/bin/grep MemTotal /proc/meminfo | awk '{print $2}'`
NOFILE=0

if [ -z $MEMTOTAL ]; then
    exit 1
fi

if [ $MEMTOTAL -ge 16770000 ]
then
    NOFILE=65536
elif [ $MEMTOTAL -ge 8380000 ]
then
    NOFILE=51200
elif [ $MEMTOTAL -ge 4190000 ]
then
    NOFILE=25600
elif [ -z $MEMTOTAL -o $MEMTOTAL -le 4189999 ]
then
    NOFILE=2048
fi

ulimit -SHn $NOFILE
/bin/grep "$NOFILE" "$LIMITS" > /dev/null ;ret=$?
if [ $ret -eq 1 ];then
cat >> $LIMITS << EOF
 *           soft   nofile       $NOFILE
 *           hard   nofile       $NOFILE
 *           soft   nproc        $NOFILE
 *           hard   nproc        $NOFILE
EOF
fi

}
sshd_config(){
    SSHD_CONFIG="/etc/ssh/sshd_config"
    SSH_CONFIG="/etc/ssh/ssh_config"
    cp $SSHD_CONFIG ${SSHD_CONFIG}.$RANDOM
    cp $SSH_CONFIG ${SSH_CONFIG}.$RANDOM
    sed -i -e 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' \
        -e 's/#UseDNS yes/UseDNS no/'\
        -e 's|#PermitEmptyPasswords\ no|PermitEmptyPasswords\ no|g'\
        -e "s|#Port\ 22|Port\ $SSH_PORT|g"\
        -e 's|ChallengeResponseAuthentication\ yes|ChallengeResponseAuthentication\ no|g'\
        -e 's|\#RSAAuthentication\ yes|RSAAuthentication\ yes|g'\
        -e 's|\#PubkeyAuthentication\ yes|PubkeyAuthentication\ yes|g' $SSHD_CONFIG
        #-e 's|#PermitRootLogin\ yes|PermitRootLogin\ no|g'\
        #sed -i 's|PasswordAuthentication\ yes|PasswordAuthentication\ no|g' $SSHD_CONFIG
    systemctl restart crond
    unset ret
    grep 'StrictHostKeyChecking no' $SSH_CONFIG >/dev/null 2>&1 ; ret=$?
    if [ $ret -ne 0 ]; then
        echo 'StrictHostKeyChecking no' >> $SSH_CONFIG
        echo 'UserKnownHostsFile /dev/null' >> $SSH_CONFIG
    fi
echo -e """
If only the key login is allowed, please: 
\033[33msed -i 's|PasswordAuthentication\ yes|PasswordAuthentication\ no|g' $SSHD_CONFIG \033[0m
If the root user is not allowed to log in, please:
\033[33msed -i 's|#PermitRootLogin\ yes|PermitRootLogin\ no|g' $SSHD_CONFIG \033[0m
systemctl restart sshd.service
"""
} 

sysctl_config(){
SYSCTL="/etc/sysctl.conf"
/bin/cp "$SYSCTL" "$SYSCTL".bak.$RANDOM
cat > $SYSCTL << 'EOF'
# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0

# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1

#Allow for more PIDs
kernel.pid_max = 65535

# The contents of /proc/<pid>/maps and smaps files are only visible to
# readers that are allowed to ptrace() the process
#kernel.maps_protect = 1

#Enable ExecShield protection
#kernel.exec-shield = 1
kernel.randomize_va_space = 2 
# Controls the maximum size of a message, in bytes
kernel.msgmnb = 65535

# Controls the default maxmimum size of a mesage queue
kernel.msgmax = 65535

# Restrict core dumps
fs.suid_dumpable = 0

# Hide exposed kernel pointers
kernel.kptr_restrict = 1

###
### IMPROVE SYSTEM MEMORY MANAGEMENT ###
###

# Increase size of file handles and inode cache
fs.file-max = 209708

# Do less swapping
vm.swappiness = 10
vm.dirty_ratio = 30
vm.dirty_background_ratio = 5

# specifies the minimum virtual address that a process is allowed to mmap
vm.mmap_min_addr = 4096

# 50% overcommitment of available memory
vm.overcommit_ratio = 50
vm.overcommit_memory = 0

# Set maximum amount of memory allocated to shm to 256MB
kernel.shmmax = 268435456
kernel.shmall = 268435456

# Keep at least 256MB of free RAM space available
vm.min_free_kbytes = 262144

###
### GENERAL NETWORK SECURITY OPTIONS ###
###

#Prevent SYN attack, enable SYNcookies (they will kick-in when the max_syn_backlog reached)
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096

# Disables packet forwarding
#net.ipv4.ip_forward = 0
net.ipv4.ip_forward = 1
#net.ipv4.conf.all.forwarding = 0
#net.ipv4.conf.default.forwarding = 0
#net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.all.forwarding = 1
#net.ipv6.conf.default.forwarding = 0

# Disables IP source routing
#net.ipv4.conf.all.send_redirects = 0
#net.ipv4.conf.default.send_redirects = 0
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv4.conf.default.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#net.ipv6.conf.default.accept_source_route = 0

# Enable IP spoofing protection, turn on source route verification
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable ICMP Redirect Acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Enable Log Spoofed Packets, Source Routed Packets, Redirect Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 7

# Decrease the time default value for connections to keep alive
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# Don't relay bootp
net.ipv4.conf.all.bootp_relay = 0

# Don't proxy arp for anyone
net.ipv4.conf.all.proxy_arp = 0

# Turn on the tcp_timestamps, accurate timestamp make TCP congestion control algorithms work better
net.ipv4.tcp_timestamps = 1

# Don't ignore directed pings
net.ipv4.icmp_echo_ignore_all = 0

# Enable ignoring broadcasts request
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Enable bad error message Protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Allowed local port range
net.ipv4.ip_local_port_range = 16384 65535

# Enable a fix for RFC1337 - time-wait assassination hazards in TCP
net.ipv4.tcp_rfc1337 = 1

# Do not auto-configure IPv6
#net.ipv6.conf.all.autoconf=0
#net.ipv6.conf.all.accept_ra=0
#net.ipv6.conf.default.autoconf=0
#net.ipv6.conf.default.accept_ra=0
#net.ipv6.conf.eth0.autoconf=0
#net.ipv6.conf.eth0.accept_ra=0

###
### TUNING NETWORK PERFORMANCE ###
###

# For high-bandwidth low-latency networks, use 'htcp' congestion control
# Do a 'modprobe tcp_htcp' first
net.ipv4.tcp_congestion_control = htcp

# For servers with tcp-heavy workloads, enable 'fq' queue management scheduler (kernel > 3.12)
net.core.default_qdisc = fq

# Turn on the tcp_window_scaling
net.ipv4.tcp_window_scaling = 1

# Increase the read-buffer space allocatable
net.ipv4.tcp_rmem = 8192 87380 16777216
net.ipv4.udp_rmem_min = 16384
net.core.rmem_default = 262144
net.core.rmem_max = 16777216

# Increase the write-buffer-space allocatable
net.ipv4.tcp_wmem = 8192 65536 16777216
net.ipv4.udp_wmem_min = 16384
net.core.wmem_default = 262144
net.core.wmem_max = 16777216

# Increase number of incoming connections
net.core.somaxconn = 32768

# Increase number of incoming connections backlog
net.core.netdev_max_backlog = 16384
net.core.dev_weight = 64

# Increase the maximum amount of option memory buffers
net.core.optmem_max = 65535

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 1440000

# try to reuse time-wait connections, but don't recycle them (recycle can break clients behind NAT)
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1

# Limit number of orphans, each orphan can eat up to 16M (max wmem) of unswappable memory
net.ipv4.tcp_max_orphans = 16384
net.ipv4.tcp_orphan_retries = 0

# Increase the maximum memory used to reassemble IP fragments
net.ipv4.ipfrag_high_thresh = 512000
net.ipv4.ipfrag_low_thresh = 446464

# don't cache ssthresh from previous connection
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_moderate_rcvbuf = 1

# Increase size of RPC datagram queue length
net.unix.max_dgram_qlen = 50

# Don't allow the arp table to become bigger than this
net.ipv4.neigh.default.gc_thresh3 = 2048

# Tell the gc when to become aggressive with arp table cleaning.
# Adjust this based on size of the LAN. 1024 is suitable for most /24 networks
net.ipv4.neigh.default.gc_thresh2 = 1024

# Adjust where the gc will leave arp table alone - set to 32.
net.ipv4.neigh.default.gc_thresh1 = 32

# Adjust to arp table gc to clean-up more often
net.ipv4.neigh.default.gc_interval = 30

# Increase TCP queue length
net.ipv4.neigh.default.proxy_qlen = 96
net.ipv4.neigh.default.unres_qlen = 6

# Enable Explicit Congestion Notification (RFC 3168), disable it if it doesn't work for you
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_reordering = 3

# How many times to retry killing an alive TCP connection
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_retries1 = 3

# Avoid falling back to slow start after a connection goes idle
# keeps our cwnd large with the keep alive connections (kernel > 3.6)
net.ipv4.tcp_slow_start_after_idle = 0

# Allow the TCP fastopen flag to be used, beware some firewalls do not like TFO! (kernel > 3.7)
net.ipv4.tcp_fastopen = 3

# This will enusre that immediatly subsequent connections use the new values
net.ipv4.route.flush = 1
net.ipv6.route.flush = 1

###
### other ###
###
vm.max_map_count=262144
#vfs_cache_pressure=200

EOF
/sbin/sysctl -p 2>&1 >/dev/null
echo "sysctl set OK!!"
}
  
selinux_config(){
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
setenforce 0
}

iptables_config(){
systemctl mask firewalld
systemctl stop firewalld.service
systemctl disable firewalld.service
yum -y install iptables-services >/dev/null 2>&1

IPTABLES="/etc/sysconfig/iptables"
IPFWS=`mktemp`
tee $IPFWS <<- EOF >/dev/null 2>&1
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport $SSH_PORT -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/ss --limit-burst 10 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
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
        xtables-multi iptables $LINE; >/dev/null 2>&1
    fi &>/dev/null
done < $IPFWS
test -f $IPTABLES && cp $IPTABLES ${IPTABLES}.$RANDOM

#docker启动会自动添加iptables rules，请不要让iptables开机自动加载默认的rules,默认rules不带docker相关的链表
#iptables-save > $IPTABLES
\rm "$IPFWS"

/usr/bin/systemctl enable iptables
/usr/bin/systemctl enable ip6tables
/usr/bin/systemctl restart iptables.service
/usr/bin/systemctl restart ip6tables
}

main(){
yum_update
zone_time
ulimit_config
sysctl_config
sshd_config
#selinux_config
#iptables_config # docker与firewalld兼容性不好,建议禁用firewalld，改为iptables。
}

if [ -f $LOCK_FILE ]; then
  echo "locking..."
  echo -e "\033[31m>>> delete $LOCK_FILE \033[0m"
  exit 1
else
  echo -e "\033[31mplease ctrl+C to cancel \033[0m"
  sleep 6
  main
  /bin/touch "$LOCK_FILE"
fi

# https://github.com/linuxsun
# 
# https://github.com/linuxsun/tools.git
# https://klaver.it/linux/sysctl.conf
# https://wiki.archlinux.org/index.php/sysctl
# https://github.com/linuxsun
