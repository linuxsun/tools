#!/usr/bin/env pytyon
# code: utf-8
import os, re, sys, platform

config_xml_file_list = []
SysTypes = platform.platform()

mystr1 = ['10.122.6.68', '%Interface%']
mystr2 = ['10.162.8.168', '%Web%']
mystr3 = ['10.161.1.88', '%Middle%']

#mystr11 = ['/M:https://%Interface_ECS_ibe%:8172/msdeploy.axd', '/M:https://%Interface_ECS_ibe%:8172/msdeploy.axd']
#mystr22 = ['/M:https://%Web_01_ECS%:8172/msdeploy.axd', '/M:https://%Interface_ECS_ibe%:8172/msdeploy.axd']
#mystr33 = ['/M:https://%Middle_01_ECS%:8172/msdeploy.axd', '/M:https://%Interface_ECS_ibe%:8172/msdeploy.axd']

#mydir = 'D:\\tmp\\'
mydir = 'D:\\Jenkins\\jobs\\'


def config_xml_path(CfgDir):
    for lists in os.listdir(CfgDir):
        path = os.path.join(CfgDir, lists)
        if os.path.isdir(path):
            if 'Linux' in repr(SysTypes):
                config_xml_file = path + '/config.xml'
                if os.path.isfile(config_xml_file):
                    config_xml_file_list.append(config_xml_file)
            elif 'Windows' in repr(SysTypes):
                config_xml_file = path + '\\config.xml'
                if os.path.isfile(config_xml_file):
                    config_xml_file_list.append(config_xml_file)
            else:
                exit()


def config_xml_files_edit(arg):
    for i in config_xml_file_list:
        open_config_xml = open(i, "r+",encoding='UTF-8')
        s = open_config_xml.read()
        open_config_xml.seek(0, 0)
        open_config_xml.write(re.sub(arg[0], arg[-1], s))
        print("正在修改:%s" % (i,))
        open_config_xml.close()


if __name__ == '__main__':
    config_xml_path(mydir)
    config_xml_files_edit(mystr1)
    config_xml_files_edit(mystr2)
    config_xml_files_edit(mystr3)

    #config_xml_files_edit(mystr22)
    #config_xml_files_edit(mystr33)


    
