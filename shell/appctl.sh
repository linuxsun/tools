#!/bin/bash
PROG_NAME=$0
ACTION=$1
ONLINE_OFFLINE_WAIT_TIME=6  # 实例上下线的等待时间
APP_START_TIMEOUT=50     # 等待应用启动的时间
APP_PORT=8080          # 应用端口
HEALTH_CHECK_URL=http://127.0.0.1:${APP_PORT}/health  # 应用健康检查URL
HEALTH_CHECK_FILE_DIR=/home/admin/status   # 脚本会在这个目录下生成nginx-status文件
APP_HOME=/home/admin/application  # 从package.tgz中解压出来的jar包放到这个目录下
JAR_NAME=app-0.1.0.jar # jar包的名字
APP_LOG=${APP_HOME}/logs/app.log # 应用的日志文件
PID_FILE=${APP_HOME}/pid   # 应用的pid会保存到这个文件中
# 创建出相关目录
mkdir -p ${HEALTH_CHECK_FILE_DIR}  
mkdir -p ${APP_HOME}
mkdir -p ${APP_HOME}/logs
usage() {
    echo "Usage: $PROG_NAME {start|stop|online|offline|restart}"
    exit 2
}
online() {
    # 挂回SLB
    touch -m $HEALTH_CHECK_FILE_DIR/nginx-status || exit 1
    echo "wait app online in ${ONLINE_OFFLINE_WAIT_TIME} seconds..."
    sleep ${ONLINE_OFFLINE_WAIT_TIME}
}
offline() {
    # 摘除SLB
    rm -f $HEALTH_CHECK_FILE_DIR/nginx-status || exit 1
    echo "wait app offline in ${ONLINE_OFFLINE_WAIT_TIME} seconds..."
    sleep ${ONLINE_OFFLINE_WAIT_TIME}
}
health_check() {
    exptime=0
    echo "checking ${HEALTH_CHECK_URL}"
    while true
    do
        status_code=`/usr/bin/curl -L -o /dev/null --connect-timeout 5 -s -w %{http_code}  ${HEALTH_CHECK_URL}`
        if [ x$status_code != x200 ];then
            sleep 1
            ((exptime++))
            echo -n -e "\rWait app to pass health check: $exptime..."
        else
            break
        fi
        if [ $exptime -gt ${APP_START_TIMEOUT} ]; then
            echo
            echo 'app start failed'
            exit 1
        fi
    done
    echo "check ${HEALTH_CHECK_URL} success"
}
start_application() {
    echo "start jar"
    if [ -f "$PID_FILE" ] && kill -0 "$(cat ${PID_FILE})"; then
        echo "Application is running, exit"
        exit 0
    fi
    rm -rf ${APP_HOME}/${JAR_NAME}
    tar -zxvf /home/admin/package.tgz -C ${APP_HOME}
    java -jar ${APP_HOME}/${JAR_NAME} > ${APP_LOG} 2>&1 &
    echo $! > ${PID_FILE}
}
stop_application() {
    echo "stop jar"
    if [ -f "$PID_FILE" ]; then
        kill -9 `cat $PID_FILE`
        rm $PID_FILE
    else
        echo "pid file $PID_FILE does not exist, do noting"
    fi
}
start() {
    start_application
    health_check
    online
}
stop() {
    offline
    stop_application
}
case "$ACTION" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    online)
        online
    ;;
    offline)
        offline
    ;;
    restart)
        stop
        start
    ;;
    *)
        usage
    ;;
esac
