
### 环境描述

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

可以参考[hadoop部署方法](http://blog.csdn.net/clark_xu/article/details/69668618) 但不可完全照搬步骤。

特别是配置文件，需要根据实际情况改动。



### 程序启动顺序

```
1. node01
/app/hadoop-2.7.1/sbin/mr-jobhistory-daemon.sh start historyserver
/app/hadoop-2.7.1/sbin/start-dfs.sh
/app/hadoop-2.7.1/sbin/start-yarn.sh

2. node01 to node04
/app/zookeeper-3.4.6/bin/zkServer.sh start

3. node01
/app/hbase-1.3.1/bin/start-hbase.sh

4. node01
nohup hive --service hwi &
cd /app/apache-hive-2.1.1-bin ; nohup bin/hive --service hiveserver2 &
```

已将启动顺序整合到node01/app/run.sh脚本,可将此脚本存放在node01节点/app/run.sh 执行：

启动 /app/run.sh start

停止 /app/run.sh stop


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

[sqldeveloper-4.1.5.21.78-x64.zip 下载地址](http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/sqldev-downloads-415-3662249.html)

[hive_jdbc插件 载地址](https://www.cloudera.com/downloads/connectors/hive/jdbc/2-5-15.html)


打开sqldeveloper.exe，点击”工具”–>“首选项”,在”数据库”–>”第三方JDBC驱动”中，添加Hive JDBC驱动：

![images](https://github.com/linuxsun/tools/blob/master/config/hadoop_config/image-sqldeveloper.png)

添加后重启sqldeveloper。

再次打开sqldeveloper，点击”新建连接”，选择”Hive”数据库：

![images2](https://github.com/linuxsun/tools/blob/master/config/hadoop_config/image-sqldeveloper-hive.png)



### 参考文档

1. https://wiki.apache.org/hadoop/QuickStart
2. http://blog.csdn.net/clark_xu/article/details/69668618
3. https://blogs.oracle.com/datawarehousing/oracle-sql-developer-data-modeler-support-for-oracle-big-data-sql

