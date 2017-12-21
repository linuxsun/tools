#!/usr/bin/env bash

HOST_NAME=$1
HOST_IP=$2

#oldifs=$IFS
#IFS=$oldifs

URL="http://192.168.204.133:2379"
URI="v2/keys/skydns"
CURL="/usr/bin/curl"

TMP=`mktemp`
cat /dev/null > $TMP
NUM=`echo $HOST_NAME | awk -F'.' '{print NF}'`
while [[ "$NUM" -ne 0 ]] && [[ "$NUM" -ne 256 ]]
do
  #echo $NUM
  #echo "$HOST_NAME" | awk -F'.' -v count=$NUM '{print $count} gsub(/\\n/,"/")'
  #echo "$HOST_NAME" | awk -F'.' -v count=$NUM '{print $count}' | sed -s 's|\n|/|g'
  echo "$HOST_NAME" | awk -F'.' -v count=$NUM '{print $count}' | tr -s '\n' '/' >> $TMP
  NUM=$(( $NUM - 1 ))
done

sed -i 's|/$||g' $TMP
echo "$CURL -XPUT $URL/$URI/$(cat $TMP) -d value='{"'host'":"'$HOST_IP'"}'"
$CURL -XPUT $URL/$URI/$(cat $TMP) -d value='{"'host'":"'$HOST_IP'"}' | /bin/json_reformat
rm $TMP

ping -c3 $HOST_NAME


# HELP
# curl -XPUT http://192.168.80.100:2379/v2/keys/skydns/mesos/marathon/nginx -d value='{"host":"192.168.80.99","port":31029}'
#
# curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/config \
#    -d value='{"dns_addr":"127.0.0.1:5354","ttl":3600, "nameservers": ["8.8.8.8:53","8.8.4.4:53"]}'
#
# curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/local/skydns/east/production/rails/1 \
#    -d value='{"host":"service1.example.com","port":8080}'
# curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/local/skydns/west/production/rails/2 \
#    -d value='{"host":"service2.example.com","port":8080}'
# curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/local/skydns/east/staging/rails/4 \
#    -d value='{"host":"10.0.1.125","port":8080}'
# curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/local/skydns/east/staging/rails/6 \
#    -d value='{"host":"2003::8:1","port":8080}'
#
# dig @localhost SRV 1.rails.production.east.skydns.local
#
# URL
# https://github.com/coredns/coredns/releases/
# http://www.cnblogs.com/boshen-hzb/p/7541901.html
# https://github.com/skynetservices/skydns
# https://coredns.io/plugins/etcd/
