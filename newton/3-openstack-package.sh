#!/bin/bash
ch_stat=/var/log/3-openstack_stat
if [ ! -f ${ch_stat} ];then
	echo "y" | apt-get install software-properties-common
	echo "y" | add-apt-repository cloud-archive:newton
	echo "y" | apt-get update 
	echo "y" | apt-get dist-upgrade
	echo "y" | apt-get install python-openstackclient
	echo "have done before !" > ${ch_stat}
fi
