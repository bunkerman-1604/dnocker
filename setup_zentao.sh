#!/bin/bash
uname=`uname -a | grep Ubuntu | wc -l`
debhttp=http://dl.cnezsoft.com/zentao/8.2.4/ZenTaoPMS_8.2.4_1_all.deb
deb=ZenTaoPMS_8.2.4_1_all.deb
rpmshttp=http://dl.cnezsoft.com/zentao/8.2.4/zentaopms-8.2.4-1.noarch.rpm
rpms=zentaopms-8.2.4-1.noarch.rpm
echo ${uname}
if [ ${uname} -eq 0 ];then
        if [ ! -f ${rpms} ];then
                wget ${rpmshttp}
                echo "y" | yum install httpd php php-cli php-common php-mysql php-json php-ldap mysql-server php-pdo
                rpm -ivh ${rpms}
                service httpd restart
        fi
else
        if [ ! -f ${deb} ];then
                wget ${debhttp}
                echo "y" | apt-get install apache2 php5 php5-cli php5-common php5-mysql php5-json php5-ldap mysql-server
                dpkg -i ${deb}
                apache2ctl restart
        fi
fi
