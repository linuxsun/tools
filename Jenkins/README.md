
## SafeUpdate.config.xml 
应用场景：
当有批量对服务器进行升级或者移除程序时，可使用此方法批量升级/移除程序. 
这种任务特别适合清理ECS云服务器某些程序存在高危漏洞时使用。

使用方法：
前往jenkins首页，创建一个名称为:SafeUpdate的自由风格任务.
然后将此SafeUpdate.config.xml上传至JENKINS_HOME/jobs/SafeUpdate/目录,替换config.xml文件.
前往 系统管理-->读取设置 重新reload配置。

部署界面
#![show](https://github.com/linuxsun/tools/blob/master/Jenkins/SafeUpdate.png)

## DownloadFiles.config.xml


