if [ -z $HBASE_HOME ]; then
    export HBASE_HOME=/app/hbase-1.3.1
    export PATH=$PATH:$HBASE_HOME/bin
fi
