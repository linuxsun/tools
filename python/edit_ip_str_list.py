#!/usr/bin/python
# -*- coding: utf-8 -*-
import os, re, sys, platform, time

OsType = platform.platform()
#sdir = r"C:\tmp"
sdir = r"/application/nginx/conf/extra"
slist = []

item = {
    'Redis-cluster01': ['10.7.228.11', '172.16.1.117'],
    'Redis-cluster02': ['10.4.33.22', '172.16.1.118'],
    'ZooKeeper01': ['10.24.5.33', '172.16.1.131'],
    'RabbitMq01': ['10.47.16.44', '172.16.1.134'],
    'RabbitMq02': ['10.24.6.55', '172.16.1.135'],
    'nginx-web': ['10.46.6.66', '172.16.1.138'],
    'hot1' : ['172.16.1.12:8081','172.16.1.182:8080'],
    'hot2' : ['172.16.1.16:8082','172.16.1.166:8080'],
}
# 'srm-rpc' : ['old','172.16.1.169'],
# 'infoservice-rpc' : ['10.25.84.74','172.16.1.181'],
# 'charge-rpc' : ['10.25.84.74','172.16.1.183'],
# 'invoice-rpc' : ['10.25.84.74','172.16.1.191'],
# '' : ['old','new'],
#    '' : ['',''],


def AddFileToSlist():
    try:
        for root, dirs, files in os.walk(sdir, topdown=False):
            for name in files:
                # print(os.path.join(root, name))
                slist.append(os.path.join(root, name))
    except OSError as ex:
        print(ex)


def EditFile(*args, **kwargs):
    for kv in kwargs:
        # print(kwargs[kv][0],kwargs[kv][-1])
        for i in args:
            # ff = open(i, "r+",encoding='UTF-8')
            ff = open(i, "r+")
            s = ff.read()
            ff.seek(0, 0)
            if kwargs[kv][0] in s:
                ff.write(re.sub(kwargs[kv][0], kwargs[kv][-1], s))
                print("正在修改:%s" % (i,))
                # time.sleep(0.1)
                ff.close()


def main():
    AddFileToSlist()
    EditFile(*slist, **item)


if __name__ == '__main__':
    main()


