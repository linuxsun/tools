#!/usr/bin/env python
import sys
import re
import os

MY_ARGV=sys.argv[1:]
HOST_NAME=MY_ARGV[0]
HOST_IP=MY_ARGV[1]

URL="http://192.168.80.100:2379"
URI="v2/keys/skydns"

MY_DNSNAME="/".join(HOST_NAME.split('.')[::-1])
VALUE={}
VALUE={"host":"null"}
VALUE["host"]=HOST_IP

#print(VALUE)
CMD="/usr/bin/curl -XPUT %s/%s/%s -d value='%r'" % (URL,URI,MY_DNSNAME,VALUE)
#print(CMD)
os.system(CMD)

# run
# >>> python add.py t10.test.dev.com 192.168.80.120 | python -mjson.tool
# /usr/bin/curl -XPUT http://192.168.80.100:2379/v2/keys/skydns/com/dev/test/t10 -d value='{"host": "192.168.80.120"}'
#                                                                                           ^    ^  ^              ^
# 
# not run
# >>> python add.py t10.test.dev.com 192.168.80.120 | python -mjson.tool
# /usr/bin/curl -XPUT http://192.168.80.100:2379/v2/keys/skydns/com/dev/test/t10 -d value='{'host': '192.168.80.120'}'
#                                                                                           ^    ^  ^              ^
# >>> ping t10.test.dev.com
# ping t10.test.dev.com: Name or service not known
