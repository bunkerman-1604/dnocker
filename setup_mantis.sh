#!/bin/bash
localIP=(`ifconfig eth0 | grep "inet " | tr -sc '[0-9.]' ' '`)
mantisdir=/home/ubuntu/mantisbt-1.2.19
mysqlpwd=123456
mantisdbpwd=mantis123!@#
tmp=`ps -aux | grep mysql | wc -l`
if [ ${tmp} -lt 2 ];then
	echo "y" | apt-get install apache2
fi
tmp=/etc/apache2/sites-available/000-default.conf
if [ -f ${tmp}.bak ];then
	cp ${tmp}.bak ${tmp}
else
	cp ${tmp} ${tmp}.bak
fi
sed -i "/#ServerName/,+0aServerName ${localIP}:80" ${tmp}
sed -i "/^ServerName ${localIP}:80/s//	ServerName ${localIP}:80/" ${tmp}
sed -i "/#ServerName/,+0aAddType application/x-httpd-php .php" ${tmp}
sed -i "/#ServerName/,+0aAddType application/x-httpd-php .html" ${tmp}
sed -i "/^AddType/s//	AddType/" ${tmp}
sed -i "/DocumentRoot/,+0a\<Directory \/\>" ${tmp}
sed -i "/DocumentRoot/s/^/#/" ${tmp}
sed -i "/Directory/,+0aOptions FollowSymLinks" ${tmp}
sed -i "/Options FollowSymLinks/s/^/		/" ${tmp}
sed -i "/Options FollowSymLinks/,+0aAllowOverride None" ${tmp}
sed -i "/AllowOverride None/s/^/		/" ${tmp}
sed -i "/AllowOverride None/,+0a\<\/Directory\>" ${tmp}
sed -i "/Directory/s/^/	/" ${tmp}
sed -i "/#ServerName/,+0aDirectoryIndex index.html default.php index.php" ${tmp}
sed -i "/^DirectoryIndex/s//	DirectoryIndex" ${tmp}
tmp=`ps -aux | grep mysql | wc -l`
if [ ${tmp} -lt 2 ];then
	echo "y" | apt-get install mariadb-server 
	mysql -uroot -p${mysqlpwd} < "grant all privileges on bugtracker.* to mantisdbuser@localhost identified by \"${mantisdbpwd}\";"
fi
echo "y" | apt-get install php5-gd
echo "y" | apt-get install php5
echo "y" | apt-get install php5-mysql
echo "y" | apt-get install libapache2-mod-php5
tmp=/etc/php5/apache2/php.ini
if [ -f ${tmp}.bak ];then
        cp ${tmp}.bak ${tmp}
else
        cp ${tmp} ${tmp}.bak
fi
sed -i "/extension=msql.so/s/;//" ${tmp}
#if [ `git | wc -l` -lt 4 ];then
#	apt-get install git
#fi
#git clone https://github.com/mantisbt/mantisbt.git
cp -R ${mantisdir} /var/www/mantis
cd /var/www/mantis
cp config_inc.php.sample config_inc.php
sed -i "\/g_db_password   = '';/s//g_db_password   = '${mantisdbpwd}';/" config_inc.php
sed -i "/g_db_type/,+0a\$g_default_language	= 'chinese_simplified';" config_inc.php
sed -i "/g_db_type/,+0a\$g_default_timezone	= 'Asia/Shanghai';" config_inc.php
service apache2 restart
