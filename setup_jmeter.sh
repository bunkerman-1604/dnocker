#!/bin/bash
. /etc/profile
jpath=/home/ubuntu
jmeterhome=${jpath}/apache-jmeter-2.13
ifconfig eth0 | grep "inet " > ${jpath}/hostIP
hostIP=(`tr -sc '[0-9.]' ' ' < ${jpath}/hostIP`)
if [ ! -d "${jmeterhome}/bin" ] ; then
        apt-get install unzip
        unzip ${jmeterhome}.zip
        chmod 777 ${jmeterhome}/bin/*
        sed -i "/jmeter.sh/,+0d " /etc/rc.local
        sed -i "/exit/,+0i /home/ubuntu/./jmeter.sh" /etc/rc.local
        sed -i "/$(hostname)/,+0d " /etc/hosts
        echo "${hostIP[0]}      $(hostname)" >> /etc/hosts
        shutdown -r now
fi
tar -zxvf ${jpath}/jmeter.tar.gz
mv ${jpath}/DouDouDownload/*.jar ${jmeterhome}/lib/ext
if [ ! -f "${jmeterhome}/bin/startMark" ] ; then
        timep=`date -d today +"%Y-%m-%d_%H:%M:%S"`
        echo "${timep}-----started jmeter" >> ${jmeterhome}/bin/startMark
        ${jmeterhome}/bin/jmeter-server
else
        rm -rf ${jmeterhome}/bin/startMark
        shutdown -r now
fi
