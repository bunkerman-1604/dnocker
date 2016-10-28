# /bin/bash
#open remoteCommand and config privillage
#echo "EnableRemoteCommands=1" > /etc/zabbix/zabbix_agentd.conf
#echo "zabbix ALL=NOPASSWD: ALL" > /etc/sudors
#mail part
function part_mail()
{
	scrpath=/usr/local/zabbix/share/zabbix/alertscripts
	mailsh=${scrpath}/sendmail.sh
	if [ ! -f ${mailsh} ] ; then
		if [ ! -d ${scrpath} ]; then
			mkdir -p ${scrpath}
		fi
		cd ${scrpath}
		echo "#!/bin/bash" > ${mailsh}
		echo "echo \"\$3\" | mail -s \"\$2\" \$1" >> ${mailsh}
		chown zabbix:zabbix ${mailsh}
		chmod +x ${mailsh}
	else
		echo "Here is a sendmail.sh exist !"
	fi
}
#yum part
function part_yum()
{
	rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
	#yum install zabbix-agent
	yum install zabbix-server-mysql zabbix-web-mysql

	# cd /usr/share/doc/zabbix-server-mysql-2.4.0/create
	# mysql -uroot zabbix < schema.sql
	# mysql -uroot zabbix < images.sql
	# mysql -uroot zabbix < data.sql

	# vi /etc/zabbix/zabbix_server.conf
	#DBHost=localhost
	#DBName=zabbix
	#DBUser=zabbix
	#DBPassword=zabbix

	# service zabbix-server start
}
#apt-get part
function part_apt()
{
	if [ $# -eq 0 ]; then
		wget http://repo.zabbix.com/zabbix/3.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.0-1+trusty_all.deb
		dpkg -i zabbix-release_3.0-1+trusty_all.deb
		apt-get update
		#apt-get install zabbix-agent -y
		apt-get install zabbix-server-mysql zabbix-frontend-php
	else
		setupFile=$1
		if [ ! -f ${setupFile} ] ; then
			echo "=================not Found zabbix tar file !"
		else
			echo "++++++++++++Please Input your mysql ROOT password !"
			read rootpw
			cd ${setupFile%/*}
			tar -zxvf ${setupFile}
			tmp1=(`ls -l | grep '^d' | grep zabbix`)
			part_sql ${setupFile%/*}/${tmp1[8]} root ${rootpw};
			part_conf_zabbix;
		fi
		service apache2 restart
	fi

}

#about mysql part
function part_sql()
{
	#insert where this sql file will be placed;
	#$1 is zabbix directory path
	sqlpath=$1
	#insert user
	logname=$2
	#insert user`s password;
	password=$3
	echo "create database zabbix character set utf8 collate utf8_bin;" > ${sqlpath%/*}/setup_zabbix.sql
	#echo "grant all privileges on zabbix.* to ${logname}@localhost identified by '${password}';" >> ${sqlpath%/*}/setup_zabbix.sql
	echo "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';" >> ${sqlpath%/*}/setup_zabbix.sql
	mysql -u${logname} -p${password} < ${sqlpath%/*}/setup_zabbix.sql
	mysql -u${logname} -p${password} zabbix < $1/database/mysql/schema.sql
	mysql -u${logname} -p${password} zabbix < $1/database/mysql/images.sql
	mysql -u${logname} -p${password} zabbix < $1/database/mysql/data.sql
	cd /usr/share/doc/zabbix-server-mysql
	mysql -u${logname} -p${password} <  zcat create.sql.gz
}
#config zabbix
function part_conf_zabbix()
{
	echo "DBHost=localhost"		>>/etc/zabbix/zabbix_server.conf	
	echo "DBName=zabbix"		>>/etc/zabbix/zabbix_server.conf	
	echo "DBUser=zabbix"		>>/etc/zabbix/zabbix_server.conf	
	echo "DBPassword=zabbix"	>>/etc/zabbix/zabbix_server.conf	

	sed -i "/# php_value date.timezone/,+0a php_value date.timezone Asia/Shanghai"        /etc/apache2/conf-available/zabbix.conf
}

#main line to setup
function part1()
{
	tarpath=$1
	cd ${tarpath%/*}
	if [ `ls -l /home/sam/ | grep '^d' | grep zabbix | wc -l` -eq 0 ]; then
		echo "Not Found zabbix directory in ${tarpath%/*} !"
		tar -zxvf ${tarpath}
	else
		echo "Found zabbix directory in ${tarpath%/*} !"
	fi
	if [ `cat /etc/group | grep zabbix | wc -l` -gt 0 ]; then
		echo "group zabbix is already created !"
	else
		groupadd zabbix
		useradd -g zabbix zabbix
	fi
	if [ `ps -aux | grep mysql | wc -l` -gt 0 ]; then
		echo "Found Mysql process running !"
	else
		echo "Not Found Mysql running !"
		apt-get install mysql-server
		tmp1=(`ls -l /home/sam/ | grep '^d' | grep zabbix`)
		echo "######################################"
		echo "###Now input mysql zabbix password####"
		echo "######################################"
		read zabbixpassword
		part_sql ${tarpath%/*}${tmp1[8]} zabbix ${zabbixpassword};
	fi
}
if [ $# -eq 0 ]; then
	echo "you need add zabbix tar file exactly path !";
#	part_apt 
	part_apt /root/zabbix_3.0.0.orig.tar.gz
else
	part1 $1; 
fi
