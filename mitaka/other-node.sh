#!/bin/bash
manageth=eth0
providereth=${manageth}
mariadbpwd=`cat control-node.sh | grep mariadbpwd= | cut -b 12-`
rabbit_passwd=`cat control-node.sh | grep rabbit_passwd= | cut -b 15-`
keystonepwd=`cat control-node.sh | grep keystonepwd= | cut -b 13-`
novadbpwd=`cat control-node.sh | grep novadbpwd= | cut -b 11-`
novapwd=`cat control-node.sh | grep novapwd= | cut -b 9-`
neutronpwd=`cat control-node.sh | grep neutronpwd= | cut -b 12-`
metadata_secret=123456
CINDER_DBPASS=`cat control-node.sh | grep CINDER_DBPASS= | cut -b 15-`
CINDER_PASS=`cat control-node.sh | grep CINDER_PASS= | cut -b 13-`
MANILA_DBPASS=`cat control-node.sh | grep MANILA_DBPASS= | cut -b 15-`
MANILA_PASS=`cat control-node.sh | grep MANILA_PASS= | cut -b 13-`
control=`cat control-node.sh | grep control= | cut -b 9-`
dns_server=`cat control-node.sh | grep dns_server= | cut -b 12-`
localnode=mitaka-37.wodezoon.com
ch_stat=/var/log/control_stat
setup_type=1

if [ ! -f ${ch_stat} ];then
	ipaddr=(`ifconfig ${manageth} | grep "inet " | tr -sc '[0-9.]' ' '`)
	echo "Your Current ${manageth} IP Adrress is ${ipaddr}"
	sed -i "/127/s/^/#/" /etc/hosts
	echo "${localnode}" > /etc/hostname
	hostname ${localnode}
	./1-host-networking.sh ${dns_server} ${manageth}
	echo "have reboot before" > ${ch_stat}
	reboot
	echo "please contiune after this reboot !"
	read thereboot
else
	ipaddr=(`ifconfig ${manageth}:0 | grep "inet " | tr -sc '[0-9.]' ' '`)
	echo "Your Current ${manageth}:0 IP Adrress is ${ipaddr}"
fi
echo "############Start/Restart NTP!"
./2-network-time-protocal.sh ${control}
echo "############Start/Restart Openstack-Package!"
./3-openstack-package.sh
if [ ${setup_type} -eq 1 ];then
	echo "############Start/Restart compute-Service ! "
	./11-compute-service-node.sh ${novadbpwd} ${rabbit_passwd} ${novapwd} ${ipaddr} ${control}
	echo "############Start/Restart networking-service.sh-Setup! "
	./15-networking-compute.sh ${rabbit_passwd} ${neutronpwd} ${control} ${providereth} ${ipaddr}
else
	echo "############Start/Restart Block Storage Service!"
	./21-Block-Storage-node.sh ${CINDER_DBPASS} ${CINDER_PASS} ${control} ${rabbit_passwd} ${ipaddr}
	echo "############Start/Restart Shared-File-System Service!"
	./23-Shared-File-System-Service-node.sh ${MANILA_DBPASS} ${MANILA_PASS} ${control} ${rabbit_passwd} ${ipaddr}
fi
