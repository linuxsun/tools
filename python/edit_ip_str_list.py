#!/usr/bin/python
# -*- coding: utf-8 -*-
import os, re, sys, platform, time

#Self = os.path.join(os.path.dirname(os.getcwd()), sys.argv[0])
Self = os.path.join(os.getcwd(), sys.argv[0])
print(Self)
OsType = platform.platform()
#sdir = r"C:\tmp"
sdir = r"/root/github.com/tools/python"
slist = []

item = {
    'cluster01': ['10.7.228.11', '172.16.11.117'],
    'cluster02': ['10.4.33.22', '172.16.11.118'],
    'Zk': ['10.24.5.33', '172.16.11.131'],
    'nginx-web': ['10.46.6.66', '172.16.11.138'],
    'hot1' : ['172.16.11.12:8081','172.16.11.182:8080'],
    'hot2' : ['172.16.11.16:8082','172.16.11.166:8080'],
}

def AddFileToSlist():
    try:
        for root, dirs, files in os.walk(sdir, topdown=False):
            for name in files:
                # print(os.path.join(root, name))
                slist.append(os.path.join(root, name))
        try:
            slist.remove(Self)
        except:
            pass
        print(slist)
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


