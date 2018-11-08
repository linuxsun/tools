
## 1. SafeUpdate.config.xml 

### 1.1 应用场景：
当有批量对服务器进行升级或者移除程序时，可使用此方法批量升级/移除程序. 
这种任务特别适合清理ECS云服务器某些程序存在高危漏洞时使用。

### 1.2 使用前提：
Jenkins采用主/从方式通信。
Jenkins需要安装ansible插件，jenkins从节点需要配置公密匙方式ssh目标服务器.

### 1.3 使用方法：
前往jenkins首页，创建一个名称为:SafeUpdate的自由风格任务.
然后将此SafeUpdate.config.xml上传至JENKINS_HOME/jobs/SafeUpdate/目录,替换config.xml文件.
前往 系统管理-->读取设置 重新reload。

### 1.4 部署界面
# ![show](https://github.com/linuxsun/tools/blob/master/Jenkins/SafeUpdate.png)

## 2. DownloadFiles.config.xml

### 2.1 应用场景：
如果云服务器处于私有网络，公司、工作网络与其不互通。
远程ssh服务器需要经过跳板机,再ssh到目标服务器,这样的情况上传文件是件非常麻烦的事情.

### 2.2 使用方法：
创建一个名称为JenkinsDownload的自由风格任务，
将DownloadFiles.config.xml传至JENKINS_HOME/jobs/JenkinsDownload/目录，替换config.xml文件.
前往 系统管理-->读取设置 重新reload。

JenkinsDownload.cli.sh 是客户端脚本工具，可远程触发构建，传递目标服务器IP和文件路径参数，
让jenkins自动去目标服务器拿到对应文件，放到${WORKSPACE}工作空间，供下载。

wget https://github.com/linuxsun/tools/blob/master/shell/JenkinsDownload.cli.sh
修改脚本里面的url、ToKen、USER、PASSWORD参数

./JenkinsDownload.cli.sh -d 10.x.y.z:/path/xyz/[FileName.tar.gz|/path/DirName]


