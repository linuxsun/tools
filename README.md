# 为什么要创建这个tools工具箱？

将日常工作中需要重复操作的事务,将它疏理出来形成脚本,提升效率.
```

```


# 一、 Shell

# 1. st_hotel_avg_price.sh
此脚本的用途：获取主要城市,四星级酒店标间含双早的平均参考价（元/间/夜）.

要查询的城市是由业务部门提供,一行一城市名称,存放在./city_name.txt文件. 

这其中涉及到查询mysql操作，查询elasticsearch操作. 

查询mysql操作是为了拿到各个城市对应的城市代码,然后根据城市代码去查询elasticsearch,得到平均参考价. 


使用帮助：
```
./st_hotel_avg_price.sh [code|price|clear] 
1 一行一城市名称,存放在 ./city_name.txt
tee ./city_name.txt <<-'EOF'
北京
上海
广州
...
EOF

2 ./st_hotel_avg_price.sh code
根据城市名称查询mysql数据库,获得城市代码.

3 ./st_hotel_avg_price.sh price [1-8]
1-8 WhoseStar酒店星级.
根据执行上一步拿到的城市代码,查询elasticsearch,
获得当时,酒店标间含双早的平均参考价(元/间/夜),
保存好./city_name_code_avg_price.${WhoseStar}.txt 文件,发送给相关人员.

4 ./st_hotel_avg_price.sh clear
清理文件 ./city_name.txt ./city_name_code_avg_price.${WhoseStar}.txt
```

# 2. JenkinsDownload.cli.sh
一个可传递参数的cli客户端工具脚本，特点是Jenkins参数化构建、远程触发构建、shell的整合。


# 3. install_mesos_master.sh install_mesos_node.sh
mesos+marathon部署脚本。

# 4. phabricator_auto_add_user.sh phabricator_auto_del_user.sh
这个脚本的功能：自动批量添加、删除 phabricator帐号。
特点是用 expect 模拟用户与shell交互，实现自动填充帐号注册信息。

# 5. jenkins_edit_confix_xml.sh
批量修改jenkins ${JENKINS_HOME}/jobs/jobs_name/config.xml文件内的参数：

numToKeep 保持构建的最大个数

artifactNumToKeep 发布包最大保留#个构建。


# 6. shell/coredns/add.sh
适用于 k8s 或者 Mesos。

CoreDns客户端脚本，可用此脚本整成到jenkins以及Dockerfile实现灵活添加A记录.

```
./add.sh 
./add.sh -p HOST_NAME IP TTL
./add.sh -f list.txt

list.txt:
b3.test.dev.io 192.168.80.103 1200
b4.test.dev.io 192.168.80.104
b5.test.dev.io 192.168.80.105 600
```

# 二、Python

# 7. python/jenkins

脚本用途：
```
1) jenkins_dingding.py:
     Jenkins与阿里钉钉机器人结合，将构建状态实时发送钉钉群。

2) jenkins_update_jobs_config_xml.py:
     如果创建了大量Jenkins jobs任务，每个jobs任务的 "丢弃旧的构建" 的默认值都需要手工修改的话，工作量很大。
     这个脚本的主要作用是方便批量修改 "丢弃旧的构建" 的默认值。
```

jenkins_update_jobs_config_xml.py 脚本使用方法

1) 创建 jenkins 自由风格任务

2) 源码管理
```
    选择git 仓库
    脚本地址: https://github.com/linuxsun/tools.git
```

3）选择 参数化构建过程
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

4）增加构建步骤 Execute shell

```
python python/jenkins/jenkins_update_jobs_config_xml.py \
$config_xml_root $daysToKeep $numToKeep $artifactDaysToKeep $artifactNumToKeep $skip_str_list

```


5) 运行
```
    运行参数化构建 Build with Parameters
    按要求输入六个参数值，开始构建。    
    Jenkins首页 --> 系统管理 --> 读取设置  --> 使生效 
    
```

jenkins_dingding.py 脚本使用方法


1) 编辑你的jobs

```
构建后操作--> Post build task --> Log text: .* --> Operation: --AND-- --> Script: python python/jenkins/jenkins_dingding.py $JOB_BASE_NAME

```

# 8. python/http_code
http状态码监控与警告消息推送到阿里钉钉群。

http_code.py

http_url.py  


# 三、playbook

# 9. playbook/ansible-tomcat8-jdk18
jenkins+ansible+playook 部署 tomcat8\jdk1.8 
jenkins参数化构建，与ansible的template模块都到用，灵活性高。
README

ansible部署 jdk1.8
```
1.1 demo
ansible-playbook -vv jdk18.yml --connection=local

1.2 custom
ansible-playbook -vv jdk18.yml --connection=local \
--extra-vars='jdk_dl_url=http://192.168.10.20/j/jdk' \
--extra-vars='jdk_version="8u111"' \
--extra-vars='jdk_version2="1.8.0_111"' \
--extra-vars='jdk_package_name="jdk-{{ jdk_version }}-linux-x64.tar.gz"' \
--extra-vars='jdk_user_name="admin"' \
--extra-vars='jdk_group_name="admin"' \
--extra-vars='jdk_work_dir="/data/java"' \
--extra-vars='jdk_home_dir="{{ jdk_work_dir }}/jdk{{ jdk_version2 }}"' \
--extra-vars='jdk_tmp_dir="/tmp"'
```
jenkins 部署jdk1.8
# ![show](https://github.com/linuxsun/tools/blob/master/playbook/ansible-tomcat8-jdk18/ansible-jdk18-build.png)


ansible 部署tomcat8
```
1.1 demo
ansible-playbook -v tomcat8.yml --connection=local

1.2 custom
ansible-playbook -v tomcat8.yml --connection=local \
--extra-vars='tomcat_version_jk="8.0.49"' \
--extra-vars='tomcat_native_version_jk="1.2.16"' \
--extra-vars='tomcat_user_name_jk=admin' \
--extra-vars='tomcat_group_name_jk=admin' \
--extra-vars='tomcat_password_jk="yg8AHjUjgjDl94dB"' \
--extra-vars='tomcat_base_dir_jk=/opt/tomcat' \
--extra-vars="tomcat_use_apr_jk=''" \
--extra-vars='tomcat_apr_install_dir_jk=""' \
--extra-vars='tomcat_port_shutdown_jk=8005' \
--extra-vars='tomcat_port_connector_jk=8080' \
--extra-vars='tomcat_port_redirect_jk=8443' \
--extra-vars='tomcat_override_uri_encoding_jk=""' \
--extra-vars='tomcat_port_ajp_jk=8009' \
--extra-vars='tomcat_java_opts_jk=""' \
--extra-vars='tomcat_catalina_opts_jk="-Xms1024M -Xmx2048M -server -XX:+UseParallelGC"' \
--extra-vars='tomcat_setenv_sh_jk=' \
--extra-vars='tomcat_tmp_dir_jk=/tmp' \
--extra-vars='tomcat_enable_gui_jk=' 
```

jenkins部署tomcat8
# ![show](https://github.com/linuxsun/tools/blob/master/playbook/ansible-tomcat8-jdk18/ansible-tomcat8-build.png)


# 10. playbook/saturn
Saturn

https://github.com/vipshop/Saturn

该脚本可实现自动部署saturn-executor以及saturn-console。


动部署saturn-executor两种方式：

10.1) 直接用ansible部署
需要提供一些参数,按实际情况调整saturn-executor.yaml

```
ansible-playbook saturn-executor.yaml \ 
--extra-vars "EXECUTOR_VERSION='2.1.0.1' \
WORK_DIR='/application/saturn' PROJEST_NAME=saturn-executor-X-Y-Z \
VIP_SATURN_ZK_CONNECTION=10.24.24.24:2181 JMX_PORT=245123 \
ENVIRONMENT_MEM='-Xms1G -Xmx2G' NAMESPACE='sa.dev.io' \
EXECUTOR=executor_009 ANSIBLE_HOST_LIST_FROM_JENKINS='host_addr'"
```

10.2) 使用jenkins部署
新创建JenkJenkins步骤时，需要选择"自由任务", 并且使用参数化构建。
saturn-executor.yaml文件内的vars变更和值，由用户点构建时提供，这样会可视化和灵活。
Jenkins是主、从模式，构建分两步： 
一步是build构建，参数化构建的参数和值，可以参考config-build.xml文件
另外一步是deploy，会在jenkins从服务器上执行，这个步骤也需要和第一步提供相同的参数，可以参考config-deploy.xml文件。

部署界面： 
# ![show](https://github.com/linuxsun/tools/blob/master/playbook/saturn/jenkins-saturn.png)


自动部署Saturn-Console:

playbook 使用方法有两种方式,原理与Saturn-executor类似。

10.3) 直接用ansible部署
参考10.1

10.4) 使用jenkins部署
参考10.2

jenkins自动构建步骤，可以参考: config-console-build.xml \ config-console-deploy.xml

部署界面:
# ![show](https://github.com/linuxsun/tools/blob/master/playbook/saturn/saturn-console-build.png)


# 11 playbook/supervisor
ansible部署supervisord脚本

```
git clone https://github.com/linuxsun/tools.git
cd playbook/supervisor;
ansible-playbook -i supervisor supervisor.yml
systemctl status supervisord.service
```

# 12 tools/playbook/aliyun_cloud_monitor.yaml

批量安装阿里云监控playbook


# 四、docker


# 13 Dockerfile/coredns
coredns部署

build
```
docker build --build-arg WORKDIR_DK="/etc/coredns" --build-arg ETCD_ADDR_DK="http://some-etcd:2379" -t coredns .
                                                                                    |    ^   |
                                                                                    | (Here) |
```

run
1) start etcd
```
docker pull elcolio/etcd
docker run -d -p 2379:2379 -p 2380:2380 -p 4001:4001 -p 7001:7001 \
-v /data/backup/dir:/data --name some-etcd elcolio/etcd:latest
                                |    ^    |
                                |  (Here) |        

see: https://hub.docker.com/r/elcolio/etcd/
```

2) start coredns
```
docker run -itd -p 0.0.0.0:53:53/udp -p 0.0.0.0:53:53 --link some-etcd:some-etcd --name coredns coredns
                                                            |         ^         |
                                                            |       (Here)      |
see: https://github.com/coreos/etcd
```





