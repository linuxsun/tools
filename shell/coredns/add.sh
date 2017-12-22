#!/usr/bin/env bash

#oldifs=$IFS
#IFS=$oldifs

URL="http://192.168.204.133:2379"
URI="v2/keys/skydns"
CURL="/usr/bin/curl"
DEFAULT_TTL="3600"

HELP () {
echo "$0 -p HOST_NAME IP TTL"
echo "$0 -f list.txt"
echo """
list.txt:
b3.test.dev.io 192.168.80.103 1200
b4.test.dev.io 192.168.80.104
b5.test.dev.io 192.168.80.105 600
"""
}

HOST_NAME=$2
HOST_IP=$3
HOST_TTL=$4
ADD_FROM_ARG () {
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
echo "$CURL -XPUT $URL/$URI/$(cat $TMP) -d value='{"'host'":"'$HOST_IP'","ttl":'$HOST_TTL'}'"
$CURL -XPUT $URL/$URI/$(cat $TMP) -d value='{"'host'":"'$HOST_IP'","ttl":'$HOST_TTL'}' | /bin/json_reformat
rm $TMP

#ping -c3 -i 0.2 $HOST_NAME >/dev/null 2>&1; ret=$?
#if [ $ret -eq 0 ]; then
#  echo "done"
#fi

}

FILE_NAME="$2"
ADD_FROM_FILE () {
while read LINE
do
  TMP=`mktemp`
  HOST_NAME=`echo $LINE|awk '{print $1}'`
  IPADDR=`echo $LINE |awk '{print $2}'`
  TTL=`echo $LINE| awk '{print $3}'`

  if [ -z "$TTL" ]; then
    TTL=$DEFAULT_TTL
  fi

  NUM=`echo $HOST_NAME | awk -F'.' '{print NF}'`
  while [[ "$NUM" -ne 0 ]] && [[ "$NUM" -ne 256 ]]
  do
    echo "$HOST_NAME" | awk -F'.' -v count=$NUM '{print $count}' | tr -s '\n' '/' >> $TMP 
    NUM=$(( $NUM - 1 ))
  done

  sed -i 's|/$||g' $TMP
  echo "$CURL -XPUT $URL/$URI/$(cat $TMP) -d value='{"'host'":"'$IPADDR'","ttl":'$TTL'}'"
  $CURL -XPUT $URL/$URI/$(cat $TMP) -d value='{"'host'":"'$IPADDR'","ttl":'$TTL'}' | /bin/json_reformat
  rm $TMP

done < $FILE_NAME
}

case "$1" in
  -p)
    if [ $# -eq 4 ]; then
      ADD_FROM_ARG
    else
      HELP
    fi
  ;;
  -f)
    if [ $# -eq 2 ]; then
      ADD_FROM_FILE
    else
      HELP
    fi
  ;;
  *)
    HELP
  ;;
esac    


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
