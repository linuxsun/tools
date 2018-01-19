```
    如果创建了大量Jenkins jobs任务，每个jobs任务的 "丢弃旧的构建" 的默认值都需要手工修改的话，工作量很大。
    这个脚本的主要作用是方便批量修改 "丢弃旧的构建" 的默认值。
    
```

## 一、创建 jnekins 自由风格任务

### 1) 源码管理
```
    选择git 仓库
    脚本地址: http://username@192.168.10.123/tools/python.git

```

### 2）选择 参数化构建过程
```
    增加六个 String Parameter
    1 名字 config_xml_root
      默认值  D:\jenkins\jobs

    2 名字 daysToKeep
      默认值 -1

    3 名字 numToKeep
      默认值 6

    4 名字 artifactDaysToKeep
      默认值 -1

    5 名字 artifactNumToKeep
      默认值 6

    6 名字 skip_str_list
      默认值 _deploy,Trunk-Project,Branches-Project,update_jobs_config_xml

```

### 3）增加构建步骤 Execute Windows batch command 
```
C:\Python27\python.exe jenkins\jenkins_update_jobs_config_xml.py %config_xml_root% %daysToKeep% %numToKeep% %artifactDaysToKeep% %artifactNumToKeep% %skip_str_list%

```


## 二、运行
```
    运行参数化构建 Build with Parameters
    按要求输入六个参数值，开始构建。    
    Jenkins首页 --> 系统管理 --> 读取设置  --> 使生效 
    
```


https://github.com/linuxsun/tools.git
