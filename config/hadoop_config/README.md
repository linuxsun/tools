
### 环境描述

mysql及zookeeper后来做了调整，不再使用本机的，但不影响部署流程说明。

```
| 节点名称 | 服务器IP 
| node01 | 192.168.80.188 |
| node02 | 192.168.80.189 |
| node03 | 192.168.80.190 |
| node04 | 192.168.80.198 |
```

```
| 节点名称 | 部署了哪些程序 
| node01 | /app/apache-hive-2.1.1-bin 、/app/apache-hive-2.1.1-src 、/app/hadoop-2.7.1 、/app/hbase-1.3.1 、/app/zookeeper-3.4.6 |
| node02 | /app/apache-hive-2.1.1-bin 、/app/apache-hive-2.1.1-src 、/app/hadoop-2.7.1 、/app/hbase-1.3.1 、/app/zookeeper-3.4.6 |
| node03 | /app/apache-hive-2.1.1-bin 、/app/apache-hive-2.1.1-src 、/app/hadoop-2.7.1 、/app/hbase-1.3.1 、/app/zookeeper-3.4.6 |
| node04 | /app/apache-hive-2.1.1-bin 、/app/apache-hive-2.1.1-src 、/app/hadoop-2.7.1 、/app/hbase-1.3.1 、/app/zookeeper-3.4.6 |
```


### 部署方法

可以参考这些文章，但不可完全照搬步骤。
特别是配置文件，需要根据实际情况改动。

![hadoop部署方法](http://blog.csdn.net/clark_xu/article/details/69668618)


### 程序启动顺序

在node01执行：
启动 /app/run.sh start
停止 /app/run.sh stop

启动脚本与停止脚本一般放在同一层目录。
```
node01
/app/hadoop-2.7.1/sbin/mr-jobhistory-daemon.sh start historyserver
/app/hadoop-2.7.1/sbin/start-dfs.sh
/app/hadoop-2.7.1/sbin/start-yarn.sh

node01 to node04
/app/zookeeper-3.4.6/bin/zkServer.sh start

node01
/app/hbase-1.3.1/bin/start-hbase.sh

node01
nohup hive --service hwi &
cd /app/apache-hive-2.1.1-bin ; nohup bin/hive --service hiveserver2 &
```

### 访问地址
```
http://192.168.80.188:50070/dfshealth.html#tab-datanode
http://192.168.80.188:8088/cluster/nodes
http://192.168.80.188:10002/logs/hive.log
http://192.168.80.188:10002/hiveserver2.jsp
192.168.80.188:10001  # 由hive监听，需要使用hive客户端工具来连接，往下看有说明。
```

一些基本的调试指令
```
hive -hiveconf hive.root.logger=DEBUG,console  # Debug  
schematool -dbType mysql -info                 # 获取架构信息
schematool -dbType derby -initSchema           # 初始化为新的Hive安装的当前模式
schematool -initSchema -dbType mysql           # 初始化元数据

/app/apache-hive-2.1.1-bin/bin/hive 
hive> show tables; 
hive> SET -v;
hive> quit;

/app/hbase-1.3.1/bin/hbase shell
hbase> status
hbase> list

jps
```

### hive客户端工具安装及使用

![sqldeveloper-4.1.5.21.78-x64.zip 下载地址](http://192.168.30.247/s/sqldeveloper-4.1.5.21.78-x64.zip)

![hive_jdbc插件 载地址](http://192.168.30.247/h/hive_jdbc_2.5.15.1040.zip)


打开sqldeveloper.exe，点击”工具”–>“首选项”,在”数据库”–>”第三方JDBC驱动”中，添加Hive JDBC驱动：

images{F214}

添加后重启sqldeveloper。

再次打开sqldeveloper，点击”新建连接”，选择”Hive”数据库：

images{F212}



### 参考文档

1. https://wiki.apache.org/hadoop/QuickStart
2. http://blog.csdn.net/clark_xu/article/details/69668618





