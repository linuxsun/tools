#!/usr/bin/env bash

BackDir="jenkins_config_xml_backup"
config_xml_tmp='./config_xml.list'
CPATH="$2"
ArgvCount="$#"

NewDirCreateList() {
    test -f $config_xml_tmp || find $CPATH -type\
    f -name 'config.xml' > $config_xml_tmp
    test -s $config_xml_tmp\
    && config_xml_list=(`cat $config_xml_tmp`)
}

ClearXmlList() {
    if [ -r $config_xml_tmp ]; then
        test -f $config_xml_tmp && rm $config_xml_tmp
        echo "delete: $config_xml_tmp"
    else
        echo "not found: config_xml_tmp"
        exit 1
    fi
}

BackupConfigXml() {
    for lst in ${config_xml_list[@]}
    do
        Lfile=${lst%*/config.xml}
        test -d $BackDir/$Lfile || mkdir -p $BackDir/$Lfile
        /bin/cp $lst $BackDir/$Lfile\
        && echo "backup src:$lst dest:$BackDir/$Lfile/${lst##*/}"
        sleep 0.3
    done
}

ConfigXmlAddList() {
    if [ -z $AddConfigXmlList ];then
        test -d $CPATH && AddConfigXmlList=\
(`grep -nr '<properties/>' $CPATH|awk -F: '{print $1}' `)\
|| AddConfigXmlList=
    else
        exit 1
    fi
}

AddConfigXml() {
    jenkins_str1='<properties>'
    jenkins_str2='  <jenkins.model.BuildDiscarderProperty>'
    jenkins_str3='    <strategy\ class="hudson.tasks.LogRotator">'
    jenkins_str4='      <daysToKeep>-1</daysToKeep>'
    jenkins_str5='      <numToKeep>10</numToKeep>'
    jenkins_str6='      <artifactDaysToKeep>-1</artifactDaysToKeep>'
    jenkins_str7='      <artifactNumToKeep>10</artifactNumToKeep>'
    jenkins_str8='    </strategy>'
    jenkins_str9='  </jenkins.model.BuildDiscarderProperty>'
    jenkins_str10='</properties>'
    jenkins_str=("$jenkins_str10" "$jenkins_str9" "$jenkins_str8"\
    "$jenkins_str7" "$jenkins_str6" "$jenkins_str5" "$jenkins_str4"\
    "$jenkins_str3" "$jenkins_str2" "$jenkins_str1")
}

EditConfigXml() {
    String=("<daysToKeep>${argsv[0]}</daysToKeep>"\ 
    "<numToKeep>${argsv[1]}</numToKeep>"\
    "<artifactDaysToKeep>${argsv[2]}</artifactDaysToKeep>"\
    "<artifactNumToKeep>${argsv[3]}</artifactNumToKeep>")
    
    for Files in `find $2 -type f -name '*config.xml'`
    do
        grep 'jenkins/jobs/' "$Files"; ret="$?"
        if [ $ret ]; then
            echo "Edit File:$Files string:${String[0]}"
            sed -i "s|<daysToKeep>.*</daysToKeep>|\
${String[0]}|g" $Files
            echo "Edit File:$Files string:${String[1]}"
            sed -i "s|<numToKeep>.*</numToKeep>|\
${String[1]}|g" $Files
            echo "Edit File:$Files string:${String[2]}"
            sed -i "s|<artifactDaysToKeep>.*</artifactDaysToKeep>|\
${String[2]}|g" $Files
            echo "Edit File:$Files string:${String[3]}"
            sed -i "s|<artifactNumToKeep>.*</artifactNumToKeep>|\
${String[3]}|g" $Files
            sleep 0.5
        else
            continue
        fi
    done
}

Help() {
Usage="""Backup \${JENKINS_HOME}/jobs/tasks/config.xml:
"$0" -b /opt/.jenkins/jobs

Add string to \${JENKINS_HOME}/jobs/tasks/config.xml: 
"$0" -a /opt/.jenkins/jobs

Edit \${JENKINS_HOME}/jobs/tasks/config.xml
"$0" -e \${JENKINS_HOME}/jobs '-1 10 -1 10'

Clear config.xml.list:
"$0" -c """
echo "$Usage"
}

case $1 in
  -b)
    if [ "$ArgvCount" -eq 2 -a -d "$2" ]; then
        NewDirCreateList
        BackupConfigXml
    else
        Help
        exit 1
    fi
  ;;
  -a)
    if [ "$ArgvCount" -eq 2 -a -d "$2" ]; then
        echo "runing..."
        ConfigXmlAddList
        AddConfigXml
        if [ -z "$AddConfigXmlList" ]; then
            echo "not found '<properties/>'"
            exit 1
        else 
            for xyz in ${AddConfigXmlList[@]}
            do
                for ijk in "${jenkins_str[@]}"
                do
                    numm=(`grep -n '<properties/>' $xyz`)
                    numm=${numm[0]%*:}
                    if [ -n "$numm" ]; then
                        sed -i "${numm}a \  $ijk" $xyz
                        echo "file:$xyz line:$numm add:$ijk"
                    else
                        continue
                    fi
                done
            if [ -n "$numm" -a -n $xyz ]; then\
            sed -i "${numm}d" $xyz ; fi
            sleep 0.5
            done
        fi
    else
        Help
        exit 1
    fi
  ;;
  -e)
    if [ "$ArgvCount" -le 3 -a -d "$2" ]; then
        argsv="$3"
        argsv=${argsv:-'-1 10 -1 10'}
        argsv=($argsv)
        EditConfigXml
    else
        Help
        exit 1
    fi
  ;;
  -c)
      ClearXmlList
  ;;
  *)
      Help 
  ;;
esac

