
## 脚本用途：
```
1. jenkins_dingding.py:
     Jenkins与阿里钉钉机器人结合，将构建状态实时发送钉钉群。


2. jenkins_update_jobs_config_xml.py:
     如果创建了大量Jenkins jobs任务，每个jobs任务的 "丢弃旧的构建" 的默认值都需要手工修改的话，工作量很大。
     这个脚本的主要作用是方便批量修改 "丢弃旧的构建" 的默认值。
    
```

## jenkins_update_jobs_config_xml.py 脚本使用方法

### 1 创建 jnekins 自由风格任务

### 1.1) 源码管理
```
    选择git 仓库
    脚本地址: http://username@192.168.10.123/tools/python.git

```

### 1.2）选择 参数化构建过程
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

### 1.3）增加构建步骤 Execute Windows batch command 
```
C:\Python27\python.exe jenkins\jenkins_update_jobs_config_xml.py %config_xml_root% %daysToKeep% %numToKeep% %artifactDaysToKeep% %artifactNumToKeep% %skip_str_list%

```


### 1.4) 运行
```
    运行参数化构建 Build with Parameters
    按要求输入六个参数值，开始构建。    
    Jenkins首页 --> 系统管理 --> 读取设置  --> 使生效 
    
```

## jenkins_dingding.py 脚本使用方法


### 2. 编辑你的jobs

```
构建后操作--> Post build task --> Log text: .* --> Operation: --AND-- --> Script: D:\Python27\python.exe D:\Python27\jenkins_dingding.py %JOB_BASE_NAME%

```



https://github.com/linuxsun/tools.git
