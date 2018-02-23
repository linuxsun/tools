if [ -z "$HADOOP_HOME" ]; then
    export HADOOP_HOME=/app/hadoop-2.7.1
    export PATH=$PATH:$HADOOP_HOME/bin
fi
