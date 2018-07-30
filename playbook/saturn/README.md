
## 一、自动部署Saturn-executor 

playbook 使用方法有两种方式：

### 1. 直接用ansible部署

需要提供一些参数,按实际情况调整saturn-executor.yaml

```
ansible-playbook saturn-executor.yaml \ 
--extra-vars "EXECUTOR_VERSION='2.1.0.1' \
WORK_DIR='/application/saturn' PROJEST_NAME=saturn-executor-X-Y-Z \
VIP_SATURN_ZK_CONNECTION=10.24.24.24:2181 JMX_PORT=245123 \
ENVIRONMENT_MEM='-Xms1G -Xmx2G' NAMESPACE='sa.dev.io' \
EXECUTOR=executor_009 ANSIBLE_HOST_LIST_FROM_JENKINS='host_addr'"
```

### 2. 使用jenkins部署

新创建JenkJenkins步骤时，需要选择"自由任务", 并且使用参数化构建。

saturn-executor.yaml文件内的vars变更和值，由用户点构建时提供，这样会可视化和灵活。

Jenkins是主、从模式，构建分两步： 

一步是build构建，参数化构建的参数和值，可以参考config-build.xml文件

另外一步是deploy，会在jenkins从服务器上执行，这个步骤也需要和第一步提供相同的参数，可以参考config-deploy.xml文件。

部署界面请参考： 
# ![show](https://github.com/linuxsun/tools/blob/master/playbook/saturn/jenkins-saturn.png)


## 二、 自动部署Saturn-Console

playbook 使用方法有两种方式,原理与Saturn-executor类似。

### 1. 直接用ansible部署
参考1.1

### 2. 使用jenkins部署
参考1.2

Jenkins自动构建步骤，可以参考: config-console-build.xml \ config-console-deploy.xml

部署界面请参考:
[show](https://github.com/linuxsun/tools/blob/master/playbook/saturn/saturn-console-build.png)

### 

https://github.com/linuxsun/tools.git
