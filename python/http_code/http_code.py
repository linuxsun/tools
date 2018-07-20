#!/usr/bin/env python
# _*_ coding:utf-8 _*_ 
import os
import re
import sys
import time
import StringIO
import pycurl
#import smtplib
#from email import encoders
#from email.header import Header
#from email.mime.text import MIMEText
#from email.utils import parseaddr, formataddr
from http_url import Http_url as url
from dingtalkchatbot.chatbot import DingtalkChatbot

#def _format_addr(s):
#    name, addr = parseaddr(s)
#    return formataddr(( \
#        Header(name, 'utf-8').encode(), \
#        addr.encode('utf-8') if isinstance(addr, unicode) \
#else addr))
#
#def mail(messg):
#    from_addr='user@shinetour.com'#raw_input('From: ')
#    password='pass'#raw_input('Password: ')
#    to_addr='email_addr@139.com'#raw_input('To: ')
#    smtp_server='smtp.exmail.qq.com'#raw_input('SMTP server: ')
#
#    msg = MIMEText(messg, 'plain', 'utf-8')
#    msg['From'] = _format_addr(u'Http Status Code <%s>' \
#    % from_addr)
#    msg['To'] = _format_addr(u'admin<%s>' % to_addr)
#    msg['Subject'] = Header(u'http code warning!!! ',\
#'utf-8').encode()
#    server = smtplib.SMTP(smtp_server, 25)
#    server.set_debuglevel(1)
#    server.login(from_addr, password)
#    server.sendmail(from_addr, [to_addr], msg.as_string())
#    server.quit()

class urlpass:
    def __init__(self):
        self.contents = ''
    def body_callback(self,buf):
        self.contents = self.contents + buf

def urlgzip(input_url):
    try:
        t = urlpass()
        c = pycurl.Curl()
        c.setopt(pycurl.WRITEFUNCTION,t.body_callback)
        c.setopt(pycurl.ENCODING, 'gzip')
        c.setopt(pycurl.URL,input_url)
        c.perform()
        http_code = c.getinfo(pycurl.HTTP_CODE)
        http_conn_time = c.getinfo(pycurl.CONNECT_TIME)
        http_pre_tran = c.getinfo(pycurl.PRETRANSFER_TIME)
        http_start_tran = c.getinfo(pycurl.STARTTRANSFER_TIME)
        http_total_time = c.getinfo(pycurl.TOTAL_TIME)
        http_size = c.getinfo(pycurl.SIZE_DOWNLOAD)
        return "http_code:%d,http_size:%d,conn_time:%.1f,\
pre_tran:%.1f,start_tran:%.1f,total_time:%.1f" % \
(http_code,http_size,http_conn_time,http_pre_tran, \
http_start_tran,http_total_time)
    except:
        print('URL Error: %s') % input_url
        #sys.exit(1)

def DingDing(ddmesg):
    xianding=DingtalkChatbot(url.rob_url)
    xianding.send_text(msg=ddmesg, is_at_all=False)

def warning_rule(args):
    try:
        urlinfo=urlgzip(args)
        total_time=int(float(urlinfo.split(',')[-1].\
split(':')[-1]))
        http_Code=int(urlinfo.split(',')[0].split(':')[1])
        Message=("url:%s\nhttp_code:%s\ntotal_time:%.1f\n")\
%(args,http_Code,total_time) 
        #print(Message)
        if total_time >= 10 or http_Code >= 400:
            #mail(Message)
            DingDing(Message)
    except:
        print('URL Error: %s') % args

if __name__ == '__main__':
    while True:
        for lineW in url.web:
            warning_rule(lineW)
            #print("sleep: %s") % url.sleep_time
            continue
        time.sleep(url.sleep_time/10)
        for lineI in url.interface:
            warning_rule(lineI)
            continue
        time.sleep(url.sleep_time/10)
        for lineM in url.middle:
            warning_rule(lineM)
            continue
        time.sleep(url.sleep_time)


