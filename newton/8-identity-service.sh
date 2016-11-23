#!/bin/bash
#MARIADBPWD=123456
MARIADBPWD=$1
#KEYSTONEPWD=123456
KEYSTONEPWD=$2
#CTL_HOST=mitaka-1.wodezoon.com
CTL_HOST=$3
#adminpwd=123456
adminpwd=$4
#demopwd=123456
demopwd=$5
ch_stat=/var/log/keystone_stat
if [ ! -f ${ch_stat} ];then
	echo "have done before" > ${ch_stat}

	echo "CREATE DATABASE keystone;" > keystone.sql
	echo "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONEPWD}';" >> keystone.sql
	echo "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONEPWD}';" >> keystone.sql
	
	mysql -uroot -p${MARIADBPWD} < keystone.sql
	rm -rf keystone.sql

	echo "y" | apt-get install keystone apache2
	if [ ! -f /etc/keystone/keystone.conf.bak ];then
		cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bak
	else
		cp /etc/keystone/keystone.conf.bak /etc/keystone/keystone.conf
	fi
	sed -i "/^connection =/cconnection = mysql+pymysql://keystone:${KEYSTONEPWD}@${CTL_HOST}/keystone" /etc/keystone/keystone.conf
	sed -i "/^#provider =/cprovider = fernet" /etc/keystone/keystone.conf
	
	cp /etc/keystone/keystone.conf tmp/keystone.conf
	
	su -s /bin/sh -c "keystone-manage db_sync" keystone
	
	keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
	keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
	keystone-manage bootstrap --bootstrap-password ${adminpwd} \
	--bootstrap-admin-url http://${CTL_HOST}:35357/v3/ \
	--bootstrap-internal-url http://${CTL_HOST}:35357/v3/ \
	--bootstrap-public-url http://${CTL_HOST}:5000/v3/ \
	--bootstrap-region-id RegionOne
	
	if [ `sudo cat /etc/apache2/apache2.conf | grep ServerName | wc -l` -eq 0 ];then
		echo "ServerName ${CTL_HOST}" >> /etc/apache2/apache2.conf
	fi
	
	service apache2 restart
	rm -f /var/lib/keystone/keystone.db
	
	echo "export OS_USERNAME=admin				" > identifiedexport
	echo "export OS_PASSWORD=${adminpwd}			" > identifiedexport
	echo "export OS_PROJECT_NAME=admin			" > identifiedexport
	echo "export OS_USER_DOMAIN_NAME=default		" > identifiedexport
	echo "export OS_PROJECT_DOMAIN_NAME=default		" > identifiedexport
	echo "export OS_AUTH_URL=http://${CTL_HOST}:35357/v3	" > identifiedexport
	echo "export OS_IDENTITY_API_VERSION=3			" > identifiedexport
	source identifiedexport
	
	openstack project create --domain default  --description "Service Project" service
	openstack project create --domain default  --description "Demo Project" demo
	openstack user create --domain default  --password ${demopwd} demo
	openstack role create user
	openstack role add --project demo --user demo user
	
	if [ ! -f /etc/keystone/keystone-paste.ini.bak ];then
		cp /etc/keystone/keystone-paste.ini /etc/keystone/keystone-paste.ini.bak
	else
		cp /etc/keystone/keystone-paste.ini.bak /etc/keystone/keystone-paste.ini
	fi
	sed -i "/^pipeline/s/admin_token_auth//" /etc/keystone/keystone-paste.ini
	cp /etc/keystone/keystone-paste.ini tmp/keystone-paste.ini
	
	echo "unset OS_TOKEN OS_URL" > identifiedexport
	source identifiedexport
	
	openstack --os-auth-url http://${CTL_HOST}:35357/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name admin --os-username admin token issue
	openstack --os-auth-url http://${CTL_HOST}:5000/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name demo --os-username demo token issue
fi

echo "export OS_PROJECT_DOMAIN_NAME=default"		>	admin-openrc
echo "export OS_USER_DOMAIN_NAME=default"		>>	admin-openrc
echo "export OS_PROJECT_NAME=admin"			>>	admin-openrc
echo "export OS_USERNAME=admin"				>>	admin-openrc
echo "export OS_PASSWORD=${adminpwd}"			>>	admin-openrc
echo "export OS_AUTH_URL=http://${CTL_HOST}:35357/v3"	>>	admin-openrc
echo "export OS_IDENTITY_API_VERSION=3"			>>	admin-openrc
echo "export OS_IMAGE_API_VERSION=2"			>>	admin-openrc

echo "export OS_PROJECT_DOMAIN_NAME=default"		>	demo-openrc
echo "export OS_USER_DOMAIN_NAME=default"		>>	demo-openrc
echo "export OS_PROJECT_NAME=demo"			>>	demo-openrc
echo "export OS_USERNAME=demo"				>>	demo-openrc
echo "export OS_PASSWORD=${demopwd}"			>>	demo-openrc
echo "export OS_AUTH_URL=http://${CTL_HOST}:5000/v3"	>>	demo-openrc
echo "export OS_IDENTITY_API_VERSION=3"			>>	demo-openrc
echo "export OS_IMAGE_API_VERSION=2"			>>	demo-openrc

#source admin-openrc
#openstack token issue
#source demo-openrc

