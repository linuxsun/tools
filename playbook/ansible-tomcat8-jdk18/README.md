# about

see https://github.com/ChristopherDavenport/ansible-role-universal-tomcat.git


# usage


git clone https://github.com/linuxsun/tools.git

cd ./tools/playbook/ansible-tomcat8-jdk18/


## 1. deploy jdk1.8

...

## 2. deploy tomcat8



### 2.1 demo

ansible-playbook -v tomcat8.yml --connection=local 


### 2.2 custom

ansible-playbook -v tomcat8.yml --connection=local \
--extra-vars='tomcat_version_jk="8.0.49"' \
--extra-vars='tomcat_native_version_jk="1.2.16"' \
--extra-vars='tomcat_user_name_jk=sysadmin' \
--extra-vars='tomcat_group_name_jk=sysadmin' \
--extra-vars='tomcat_password_jk="yg8AHjUjgjDl94dB"' \
--extra-vars='tomcat_base_dir_jk=/opt/tomcat' \
--extra-vars='tomcat_use_apr_jk=false' \
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





