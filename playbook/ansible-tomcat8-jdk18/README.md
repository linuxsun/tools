# about

see https://github.com/ChristopherDavenport/ansible-role-universal-tomcat.git


# usage


git clone https://github.com/linuxsun/tools.git

cd ./tools/playbook/ansible-tomcat8-jdk18/

download JDK 1.8

http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html


download tomcat8

https://tomcat.apache.org/download-80.cgi

## 1. deploy jdk1.8

### 1.1 demo

ansible-playbook -vv jdk18.yml --connection=local


### 1.2 custom

```
ansible-playbook -vv jdk18.yml --connection=local \
--extra-vars='jdk_dl_url=http://192.168.10.20/j/jdk' \
--extra-vars='jdk_version="8u111"' \
--extra-vars='jdk_version2="1.8.0_111"' \
--extra-vars='jdk_package_name="jdk-{{ jdk_version }}-linux-x64.tar.gz"' \
--extra-vars='jdk_user_name="admin"' \
--extra-vars='jdk_group_name="admin"' \
--extra-vars='jdk_work_dir="/data/java"' \
--extra-vars='jdk_home_dir="{{ jdk_work_dir }}/jdk{{ jdk_version2 }}"' \
--extra-vars='jdk_tmp_dir="/tmp"'

```


## source /etc/profile.d/java.sh


## 2. deploy tomcat8


### 2.1 demo

ansible-playbook -v tomcat8.yml --connection=local 


### 2.2 custom

```
ansible-playbook -v tomcat8.yml --connection=local \
--extra-vars='tomcat_version_jk="8.0.49"' \
--extra-vars='tomcat_native_version_jk="1.2.16"' \
--extra-vars='tomcat_user_name_jk=admin' \
--extra-vars='tomcat_group_name_jk=admin' \
--extra-vars='tomcat_password_jk="yg8AHjUjgjDl94dB"' \
--extra-vars='tomcat_base_dir_jk=/opt/tomcat' \
--extra-vars="tomcat_use_apr_jk=''" \
--extra-vars='tomcat_apr_install_dir_jk=""' \
--extra-vars='tomcat_port_shutdown_jk=8005' \
--extra-vars='tomcat_port_connector_jk=8080' \
--extra-vars='tomcat_port_redirect_jk=8443' \
--extra-vars='tomcat_override_uri_encoding_jk=""' \
--extra-vars='tomcat_port_ajp_jk=8009' \
--extra-vars='tomcat_java_opts_jk=""' \
--extra-vars='tomcat_catalina_opts_jk="-Xms1024M -Xmx2048M -server -XX:+UseParallelGC"' \
--extra-vars='tomcat_setenv_sh_jk=' \
--extra-vars='tomcat_tmp_dir_jk=/tmp' \
--extra-vars='tomcat_enable_gui_jk=' 

```




