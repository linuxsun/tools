if [ -z $JAVA_HOME -a -z $CLASSPATH ]; then
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.151-1.b12.el7_4.x86_64
    export PATH=$PATH:$JAVA_HOME/bin
    export CLASSPATH=$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
    export JRE_HOME=$JAVA_HOME/jre/bin
fi
