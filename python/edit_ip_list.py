#!/usr/bin/python
# -*- coding: utf-8 -*-
import os, re, sys, platform, time

Self = os.path.join(os.getcwd(), sys.argv[0])
OsType = platform.platform()
#sdir = r"C:\tmp"
#sdir = r"/application/nginx/conf/extra"
sdir = r"/home/sysadmin/.jenkins/jobs"
slist = []
add_file_type = '.xml'

item = {
    'hotel1' : ['172.16.11.182:8081','172.16.19.18:8080'],
    'hotel2' : ['172.16.12.166:8082','172.16.19.16:8080'],
    'srm' : ['100.115.148.22','172.16.1.20'],
}

def AddFileToSlist():
    try:
        num=0
        for root, dirs, files in os.walk(sdir, topdown=False):
            for name in files:
                # print(os.path.join(root, name))
                #slist.append(os.path.join(root, name))
                file = os.path.join(root, name)
                #print(file) 
                #print(add_file_type in file) 
                #time.sleep(1)
                #if os.path.isfile(file) and os.access(file,os.W_OK):
                if os.path.isfile(file) and os.access(file,os.W_OK) and add_file_type in file:
                    #slist.append(os.path.join(root, name))
                    slist.append(file)
                    num += 1
        print("共匹配到%s个文件." % num)
        print("文件列表长度：%s" % len(slist))
        try:
            slist.remove(Self)
        except:
            pass
    except OSError as ex:
        print(ex)


def EditFile(*args, **kwargs):
    for kv in kwargs:
        # print(kwargs[kv][0],kwargs[kv][-1])
        for i in args:
            # ff = open(i, "r+",encoding='UTF-8')
            #ff = open(i, "r+")
            with open(i, "r+") as ff:
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


