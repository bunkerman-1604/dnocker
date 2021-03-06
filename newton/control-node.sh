#!/bin/bash
eth01=eth0
eth02=eth1
rabbit_passwd=123456
mariadbpwd=mysql123!@#
keystonepwd=123456
adminpwd=admin123!@#
demopwd=demo123!@#
glancedbpwd=123456
glancepwd=glance123!@#
novadbpwd=123456
novapwd=nova123!@#
neutrondbpwd=123456
neutronpwd=neutron123!@#
metadata_secret=123456
CINDER_DBPASS=123456
CINDER_PASS=cinder123!@#
MANILA_DBPASS=123456
MANILA_PASS=manila123!@#
control=mitaka-36.wodezoon.com
ipaddr=(`ifconfig ${eth01} | grep "inet " | tr -sc '[0-9.]' ' '`)
dns_server=192.168.11.254
startip=192.168.11.100
endip=192.168.11.200
gateway=192.168.11.1
cid=192.168.11.0/24
ch_stat=/var/log/control_stat

if [ ! -f ${ch_stat} ];then
	echo "Your Current ${eth01} IP Adrress is ${ipaddr}"
	sed -i "/127/s/^/#/" /etc/hosts
	echo "${control}" > /etc/hostname
	hostname ${control}
	./1-host-networking.sh ${dns_server} ${eth01} ${eth02}
	echo "have reboot before" > ${ch_stat}
	reboot
	echo "please contiune after this reboot !"
	read thereboot
else
	ipaddr=(`ifconfig ${eth01} | grep "inet " | tr -sc '[0-9.]' ' '`)
	echo "Your Current ${eth01} IP Adrress is ${ipaddr}"
fi
echo "############Start NTP!"
./2-network-time-protocal.sh ${control} ${ipaddr}
echo "############Start Openstack-Package!"
./3-openstack-package.sh
echo "############Start SQL-Setup!"
./4-SQL-database.sh ${ipaddr} ${mariadbpwd}
#echo "############Start mongo-Setup!"
#./5-nosql-database.sh ${ipaddr}
echo "############Start message-queue-Setup!"
./6-message-queue.sh ${rabbit_passwd}
echo "############Start memcached-Setup!"
./7-memcached.sh ${ipaddr}
echo "############Start identity-service-Setup!"
./8-identity-service.sh ${mariadbpwd} ${keystonepwd} ${control} ${adminpwd} ${demopwd}
echo "############Start image-service-Setup!"
./9-image-service.sh ${mariadbpwd} ${glancedbpwd} ${glancepwd} ${control}
echo "############Start compute-service-Setup!"
./10-compute-service.sh ${mariadbpwd} ${novadbpwd} ${rabbit_passwd} ${novapwd} ${ipaddr} ${control}
echo "############Start networking-service.sh-Setup!"
echo "./12-networking-service.sh ${control} ${mariadbpwd} ${neutrondbpwd} ${neutronpwd} ${metadata_secret} ${rabbit_passwd} ${novapwd} ${control} ${eth02} ${ipaddr}"
./12-networking-service.sh ${control} ${mariadbpwd} ${neutrondbpwd} ${neutronpwd} ${metadata_secret} ${rabbit_passwd} ${novapwd} ${control} ${eth02} ${ipaddr}
echo "############Start dashboard Setup!"
./16-myop-dashborad.sh ${control}
echo "############Start Create LAN and sublan 192.168.168.0/24 Setup!"
./17-Create-the-self-service-network.sh ${dns_server} ${startip} ${endip} ${gateway} ${cid}
echo "############Start Block Storage service Setup!"
echo "./20-Block-Storage-controll.sh ${mariadbpwd} ${CINDER_PASS} ${CINDER_DBPASS} ${control} ${rabbit_passwd} ${ipaddr}"
read tmp
if [[ $tmp = "y" || $tmp = "Y" ]]; then
	./20-Block-Storage-controll.sh ${mariadbpwd} ${CINDER_PASS} ${CINDER_DBPASS} ${control} ${rabbit_passwd} ${ipaddr}
fi
echo "############Start Shared File System service Setup!"
echo "./21-Shared-File-System-Service.sh ${mariadbpwd} ${MANILA_DBPASS} ${MANILA_PASS} ${control} ${rabbit_passwd} ${ipaddr}"
read tmp
if [[ $tmp = "y" || $tmp = "Y" ]]; then
	./21-Shared-File-System-Service.sh ${mariadbpwd} ${MANILA_DBPASS} ${MANILA_PASS} ${control} ${rabbit_passwd} ${ipaddr}
fi
