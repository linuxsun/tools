#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import time
from jenkinsapi.jenkins import Jenkins
from dingtalkchatbot.chatbot import DingtalkChatbot

jobs_name=sys.argv[1].decode('gbk').encode('utf-8')
jenkins_user='admin'
jenkins_password='admin'
jenkins_url='http://localhost:8080/'
access_token='64bit_token_vars'
webhook='https://oapi.dingtalk.com/robot/send?access_token='+access_token

def JenkinsApi(jobs_name,jenkins_user,jenkins_password,jenkins_url):
    server = Jenkins(jenkins_url,username=jenkins_user,password=jenkins_password)
    job_instance = server.get_job(jobs_name)
    running = job_instance.is_queued_or_running()
    #if not running:
    latestBuild=job_instance.get_last_build()
    return 'jobs_name:%s,\nstatus:%s,\ntime:%s\n' % \
(jobs_name,latestBuild.get_status(),time.strftime('%Y-%m-%d:%H:%M:%S'))

def send_messages(message):
    WebHook=webhook
    DingDing=DingtalkChatbot(WebHook)
    DingDing.send_text(msg=message, is_at_all=False)

if __name__ == '__main__':
    messages=JenkinsApi(jobs_name,jenkins_user,jenkins_password,jenkins_url)
    print(messages)
    send_messages(messages)

"""
Help

$ pip install DingtalkChatbot
$ python
>>> from dingtalkchatbot.chatbot import DingtalkChatbot
>>> webhook='https://oapi.dingtalk.com/robot/send?access_token=XYZ'
>>> xianding=DingtalkChatbot(webhook)
>>> xianding.send_text(msg='test_group_message...', is_at_all=False)
    {u'errcode': 0, u'errmsg': u'ok'}
>>> quit()
$ 

$ pip install jenkinsapi
$ python
>>> from jenkinsapi.jenkins import Jenkins
>>> jenkins_url='http://localhost:8080/'
>>> server = Jenkins(jenkins_url,username='username',password='mypassword')
>>> job_instance = server.get_job('JenkinsJobsName')
>>> running = job_instance.is_queued_or_running()
>>> if not running:
	latestBuild=job_instance.get_last_build()
	print latestBuild.get_status()

	
SUCCESS
>>> quit()
$ 

https://github.com/zhuifengshen/DingtalkChatbot
https://serverfault.com/questions/309848/how-do-i-check-the-build-status-of-a-jenkins-build-from-the-command-line

"""
