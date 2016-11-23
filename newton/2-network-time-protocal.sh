#!/bin/bash
ipcid=$2
ch_stat=/var/log/chrony_stat
if [ ! -f ${ch_stat} ];then
	echo "y" | apt-get install chrony
	sed -i "/^server/s/^/#/"		/etc/chrony/chrony.conf
	echo "server $1 iburst"		>>	/etc/chrony/chrony.conf
	echo "allow ${ipcid%.*}.0/24"	>>	/etc/chrony/chrony.conf
	echo "the config is done !"	>	${ch_stat}
	cp /etc/chrony/chrony.conf tmp/chrony.conf
fi
service chrony restart
