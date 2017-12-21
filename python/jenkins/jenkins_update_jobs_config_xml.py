#!/usr/bin/env pytyon
import os
import re
import sys
import platform

jenkins_argv=sys.argv[1:]
config_xml_file_list = []
SysTypes = platform.platform()

def Help():
    print("C:\Python27\python.exe jenkins_update_jobs_config_xml.py E:\jenkins_jobs -1 5 -1 5 str1,str2,...")


def config_xml_path(CfgDir):
    for lists in os.listdir(CfgDir):
        path = os.path.join(CfgDir, lists)
        if os.path.isdir(path):
            if 'Linux' in repr(SysTypes): 
                config_xml_file=path + '/config.xml'
                if os.path.isfile(config_xml_file):
                    config_xml_file_list.append(config_xml_file)
            elif 'Windows' in repr(SysTypes):
                config_xml_file=path + '\\config.xml'
                if os.path.isfile(config_xml_file):
                    config_xml_file_list.append(config_xml_file)
            else:
                exit()


def config_xml_files(skip,config):
    ss = skip.split(',')
    for x in ss:
        for y in config:
            if x in y:
                num = config.index(y) 
                config.pop(num)


def config_xml_files_edit(arg):
    for i in config_xml_file_list:
        open_config_xml=open(i, "r+")
        s=open_config_xml.read()
        open_config_xml.seek(0,0)
        open_config_xml.write(re.sub(arg[0],arg[-1],s))
        open_config_xml.close()


if __name__ == '__main__':
    if len(jenkins_argv) != 6:
        STATUS=0
        Help()
        exit
    else:
        STATUS=1
        config_xml_root=jenkins_argv[0]
        skip_str_list = jenkins_argv[5]
        daysToKeep=[]
        numToKeep=[]
        artifactDaysToKeep=[]
        artifactNumToKeep=[]

        daysToKeep.append("<daysToKeep>.+</daysToKeep>")
        daysToKeepStr="<daysToKeep>%s</daysToKeep>" % jenkins_argv[1]
        daysToKeep.append(daysToKeepStr)

        numToKeep.append("<numToKeep>.+</numToKeep>")
        numToKeepStr="<numToKeep>%s</numToKeep>" % jenkins_argv[2]
        numToKeep.append(numToKeepStr)

        artifactDaysToKeep.append("<artifactDaysToKeep>.+</artifactDaysToKeep>")
        artifactDaysToKeepStr="<artifactDaysToKeep>%s</artifactDaysToKeep>" % jenkins_argv[3]
        artifactDaysToKeep.append(artifactDaysToKeepStr)

        artifactNumToKeep.append("<artifactNumToKeep>.+</artifactNumToKeep>")
        artifactNumToKeepStr="<artifactNumToKeep>%s</artifactNumToKeep>" % jenkins_argv[4]
        artifactNumToKeep.append(artifactNumToKeepStr)



    if STATUS == 1 : 
        config_xml_path(config_xml_root)
        config_xml_files(skip_str_list,config_xml_file_list)
        config_xml_files_edit(daysToKeep)
        config_xml_files_edit(numToKeep)
        config_xml_files_edit(artifactDaysToKeep)
        config_xml_files_edit(artifactNumToKeep)



