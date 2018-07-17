#!/usr/bin/env python
# _*_ coding:utf-8 _*_

class Http_url(object):

    '''
    滑动HH的值,可调整监控频率.
    每间隔 1,2,6,60 秒钟,运行一次http状态码扫描. 
    HH=60;MM=60;SS=(HH/MM);sleep_time=SS;sleep_time 
    HH=120;MM=60;SS=(HH/MM);sleep_time=SS;sleep_time
    HH=360;MM=60;SS=(HH/MM);sleep_time=SS;sleep_time
    HH=3600;MM=60;SS=(HH/MM);sleep_time=SS;sleep_time
    钉钉群自定义机器人（每个机器人每分钟最多发送20条），支持文本（text）、连接（link）、markdown三种消息类型！

    $ pip install DingtalkChatbot
    $ python
    >>> from dingtalkchatbot.chatbot import DingtalkChatbot
    >>> webhook='https://oapi.dingtalk.com/robot/send?access_token=XYZ'
    >>> xianding=DingtalkChatbot(webhook)
    >>> xianding.send_text(msg='test_group_message...', is_at_all=False)
        {u'errcode': 0, u'errmsg': u'ok'}
    >>> quit()
    $ 

    https://github.com/zhuifengshen/DingtalkChatbot
    '''

    HH=3600;MM=60;SS=(HH/MM);sleep_time=SS;sleep_time
    access_token='XYZ'
    rob_url='https://oapi.dingtalk.com/robot/send?access_token=' + access_token
 
    interface=[
    'http://url.ip:9301/test.html',
    'http://url.ip:9300/test.html',
    
    ]

    middle=[
    'http://url.ip:8060/test.html',
    'http://100.114.151.156:9000/test.html',
    
    ]

    web=[
    'http://url.ip:8800/test.html',
    'http://url.ip:8081/test.html',
    
    ]

if __name__ == '__main__':
    url=Http_url()

