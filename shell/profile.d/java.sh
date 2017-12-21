JDK_PATH="/application/java/jdk1.8.0_111"

if [ "$#" -eq 0 ]; then
    VARS=set
else
    VARS="$1"
fi

case $VARS in
  set)
  if [ -z $JAVA_HOME -a -z $CLASSPATH ]; then
    export JAVA_HOME=$JDK_PATH
    export PATH=$PATH:$JAVA_HOME/bin
    export CLASSPATH=$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
    export JRE_HOME=$JAVA_HOME/jre/bin
    unset JDK_PATH
  fi
;;
  unset)
  if [ "$VARS" = "unset" ]; then
    export JAVA_HOME=
    export CLASSPATH=
    export JRE_HOME=
    export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
    unset JDK_PATH
  fi
;;
esac
