#!/usr/bin/env python3
# coding: utf-8
import threading
import os,sys,re,time

sdir = r"D:\jobs"
Self = os.path.join(os.getcwd(), sys.argv[0])
#lock = threading.Lock()
item = {
    'ecs': ['10.122.6.68', '172.16.11.125'],
    'web': ['10.162.8.168', '172.16.11.126'],
    'xyz': ['abc','X-Y-Z'],
}
item_reverse = {
    'ecs': ['172.16.11.125', '10.122.6.68'],
    'Web': ['172.16.11.126', '10.162.8.168'],
    'xyz': ['X-Y-Z','abc'],
}

# r is f
# n is file
def EditFile(kwargs):
    """消费者"""
    f = '' # r is f
    ConsumerFilesCount = 0
    EditFilesCount = 0
    while True:
        #lk.acquire()
        n = yield f # n is file
        if not n:
            return
        print('[CONSUMER] Consuming %s' % n)
        for kv in kwargs:
            # with open(n, "r+",encoding='utf-8') as ff:
            # with open(n, "r+") as ff:
            with open(n, "r+", encoding="unicode_escape") as ff:
                s = ff.read()
                ff.seek(0, 0)
                if kwargs[kv][0] in s:
                    print("正在编辑:%s" % n)
                    ff.write(re.sub(kwargs[kv][0], kwargs[kv][-1], s))
                    EditFilesCount += 1
            ff.close()
        ConsumerFilesCount += 1
        # lk.release()
        print("线程名称：%s，文件名称：%s，对文件编辑次数：%s，共消费次数：%s" % \
              (threading.current_thread().getName(),n,EditFilesCount,ConsumerFilesCount))
        f = 'done'

# r is f
# n is file
def AddFileToQueue(c):
    """生产者"""
    c.send(None) # 预激活协程,方法1: c.send(None),方法2: next(c)
    FilesCount = 0
    num = True
    while num:
        try:
            for root, dirs, files in os.walk(sdir, topdown=False):
                for name in files:
                    file = os.path.join(root, name)
                    if os.path.isfile(file) and \
                            os.access(file,os.W_OK) and \
                            file != Self: #排除自身。请匆将脚本自身放到sdir目录。
                        print('[PRODUCER] Producing %s' % file)  #n is file
                        f = c.send(file)
                        print('[PRODUCER] Consumer return: %s' % f) # r is f
                        FilesCount += 1
            else:
                num = False
                print("对%s目录扫描完毕，符合条件并生产了%s个文件。" % (sdir,FilesCount))
        except OSError as ex:
            num = False
            print(ex)
    c.close()

def main():
    """
    # 将嵌套循环，优化为单层循环。时间复杂度为: T(n) = O(f(n))。
    # 使用了协程，边生产边消费，不需要将目录内的所有文件存放在一个list列表内，大大节省了内存空间。
    # 函数EditFile以及AddFileToQueue，各有一个for循环(不计while循环)，复杂度取最大那个即可。复杂度取值法则：加法法则、取最大值法则...
    # 扩展思考：能否使用多线程+队列queue.Queue(num)扩展一下，进一步提升效率呢？\
    # 答：回答这个问题，要先知道效率低的原因：
    # 1. 生产者和消费者只在一个线程内处理数据，只能单线程处理没办法多线程并发处理。
    # 2 虽然协程没有线程锁的概念，但是在这个项目里，同一时间对一个文件只能修改一次，这相当于自带锁了。
    # 所以，用协程没办法优化。
    # 用一个生产者1p，多个消费者nc只往队列缓冲区里放文件，然后再用多线程从队列缓冲区取出文件并修改，可能可行。但比较复杂。
    """
    #consumer = EditFile(item)
    consumer = EditFile(item_reverse)
    AddFileToQueue(consumer)

    # [threading.Thread(target=EditFile,args=(lock,item[value])).start() for index,value in enumerate(item)]
    # task = [threading.Thread(target=EditFile,args=(lock,item[value])) for index,value in enumerate(item)]
    # for i in task:
    #     AddFileToQueue(i.start())
    #AddFileToQueue(task.start())

    # for index,value in enumerate(item): # 消费者线程数，根据item的keys数量而定。
    #                       # 一对需要替换字符对应一个线程，绕过了嵌套循环。
    #                       # 将时间复杂度从嵌套循环，优化为单层循环O(n)。
    #                       # 时间复杂度为: T(n) = O(f(n))
    #     t_consume = threading.Thread(target=EditFile,args=(lock,item[value]))
    # AddFileToQueue(t_consume.start())

if __name__ == '__main__':
    main()

