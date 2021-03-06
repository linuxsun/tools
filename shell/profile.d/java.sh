#!/usr/bin/env bash
DEFAULT_JDK_PATH="/data/java/jdk1.8.0_111"
DEST="/etc/profile.d/java.sh"
VARS=0
hava_tty=0

if [ "`tty`" != "not a tty" ]; then
    have_tty=1
fi

if [ "$#" -eq 2 ]; then
    VARS=$1
    JDK_PATH=$2
elif [ "$#" -eq 1 ]; then
    VARS=$1
    JDK_PATH=$DEFAULT_JDK_PATH
else
    VARS=set
    JDK_PATH=$DEFAULT_JDK_PATH
fi

HELP(){
  echo -e """\033[31m>>> /bin/cp java.sh $DEST
>>> source $DEST [set /data/java/jdkX.Y.Z_XYZ] OR [set|unset] \033[0m"""
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
