#!/usr/bin/env bash
JDK_PATH="/application/java/jdk1.8.0_111"
hava_tty=0

if [ "`tty`" != "not a tty" ]; then
    have_tty=1
fi

if [ "$#" -eq 0 ]; then
    VARS=set
else
    VARS="$1"
fi

HELP(){
  echo "source /etc/profile.d/java.sh [set|unset]"
}

case $VARS in
  set)
  if [ $have_tty -eq 1 ] && [ -z $JAVA_HOME -a -z $CLASSPATH ]; then
    export JAVA_HOME=$JDK_PATH
    export PATH=$PATH:$JAVA_HOME/bin
    export CLASSPATH=$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
    export JRE_HOME=$JAVA_HOME/jre/bin
    unset JDK_PATH
    unset hava_tty
  fi
;;
  unset)
  if [ $have_tty -eq 1 ] && [ "$VARS" = "unset" ]; then
    export JAVA_HOME=
    export CLASSPATH=
    export JRE_HOME=
    export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
    unset JDK_PATH
    unset hava_tty
  fi
;;
  *)
    HELP
;;
esac

# https://github.com/linuxsun/tools.git


