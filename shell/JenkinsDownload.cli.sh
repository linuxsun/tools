#!/usr/bin/env bash

url='http://192.168.20.20:8080/view/pre-UploadDownloadFiles/job/pre-DownloadFiles-deploy'
ToKen="YouJenkinsToKen"
USER="YouUserName"
PASSWORD="YouPassword"
FILES="$2"
VARS=""
IP=""
is_local=""  # local=[ "192.", "172.", "128.", ]
is_aliyun="" # aliyun=[ "10.", ]

Help () {
    echo """$0 [-f|-d] [xyz]
-f /path/xyz/FileName
-d 10.x.y.z:[/path/xyz/FileName|/path/DirName]
"""
}

IpAddr () {
    ETH=$(ip addr | grep -o "2: [a-z0-9]......" | cut -d':' -f2 | tr -d ' ')
    ip addr show $ETH > /dev/null 2>&1; ret=$?
    if [ $ret -eq 0 ]; then
        set -o nounset -o errexit
        IP=$(ip addr show $ETH | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    fi
    #echo "$IP"
}

CheckIp () {
    IPADDR=`echo ${FILES%%:*}`
    if echo $IP | grep '10.' ; then
        is_aliyun="yes"
    elif echo $FILES |grep ':' ; then
        is_local="yes"
    fi
    #echo "is_aliyun: $is_aliyun"
    #echo "is_local: $is_local"
}

CheckFiles () {
    FILE=`echo ${FILES##*:}`

}

if [ $# -ne 2 ]; then
    Help
    exit 1
fi

case $1 in
    -d )
      IpAddr
      CheckIp
      CheckFiles
      #echo "$IPADDR:$FILE"
      if [ -n $IP -a "$is_aliyun" = 'yes' ] && [ -d $FILE -o -f $FILE ]; then
        #echo "$IP:$FILES"
        #curl -u $USER:$PASSWORD -X POST "$url/buildWithParameters?token=$ToKen&DestHost=$FILES&var2=test2&var3=test3"
        curl -u $USER:$PASSWORD -X POST "$url/buildWithParameters?token=$ToKen&DestHost=$IP:$FILE&var2=test2&var3=test3"
      elif [ -n $IPADDR -a "$is_local" = 'yes' ]; then
        curl -u $USER:$PASSWORD -X POST "$url/buildWithParameters?token=$ToKen&DestHost=$IPADDR:$FILE&var2=test2&var3=test3"
      else
        Help
      fi
      ;;
    -f )
        if [ -f $2 ]; then
          curl -X POST "$url"/build --user $USER:$PASSWORD --form file0=\@$2 \
--form json='{"parameter": [{"name":"DownloadFile.gz", "file":"file0"}]}'
        else
          Help
        fi
	;;
    *)
        Help
    ;;
esac



