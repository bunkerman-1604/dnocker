#!/bin/bash
. /etc/profile
ESAdd=$(pwd)/elasticsearch-1.5.0
dataAdd=/home/ubuntu
ES_HEAP_SIZE=4096
clustername="deployed-es1"
echo "put this node name:"
read nodename

if [ ! -d ${dataAdd}/conf ] ; then
        mkdir ${dataAdd}/conf
fi
if [ ! -d ${dataAdd}/datafile ] ; then
        mkdir ${dataAdd}/datafile
fi

localip=(`ifconfig eth0 | grep "inet addr" | tr -sc '[0-9.]' ' '`)
SerIP=${localip[0]}

sed -i "/node.name:/,+0d" ${ESAdd}/config/elasticsearch.yml
echo "node.name: \"${nodename}\"" >> ${ESAdd}/config/elasticsearch.yml
sed -i "/cluster.name:/,+0d" ${ESAdd}/config/elasticsearch.yml
echo "cluster.name: ${clustername}" >> ${ESAdd}/config/elasticsearch.yml
sed -i "/network.host/,+0d" ${ESAdd}/config/elasticsearch.yml
echo "network.host: ${SerIP}" >> ${ESAdd}/config/elasticsearch.yml
sed -i "/index.ana/,+0d" ${ESAdd}/config/elasticsearch.yml
echo "index.analysis.analyzer.ik.type : 'ik'" >> ${ESAdd}/config/elasticsearch.yml
#sed -i "/path.conf/,+0d" ${ESAdd}/config/elasticsearch.yml
#echo "path.conf: ${dataAdd}/conf" >> ${ESAdd}/config/elasticsearch.yml
#sed -i "/path.data/,+0d" ${ESAdd}/config/elasticsearch.yml
#echo "path.data: ${dataAdd}/datafile" >> ${ESAdd}/config/elasticsearch.yml

sed -i "/^set.default.ES_HEAP_SIZE/cset.default.ES_HEAP_SIZE=${ES_HEAP_SIZE}" ${ESAdd}/bin/service/elasticsearch.conf
sed -i "/^set.default.JAVA_HOME/cset.default.JAVA_HOME=/root/jdk1.8.0_45/" ${ESAdd}/bin/service/elasticsearch.conf

chmod 777 ${ESAdd}
chmod 777 ${ESAdd}/bin/
chmod 777 ${dataAdd}/conf/
chmod 777 ${dataAdd}/datafile/
chmod 777 ${ESAdd}/lib/
chmod 777 ${ESAdd}/plugins/
chmod 777 ${ESAdd}/bin/service/
chmod 777 ${ESAdd}/plugins/analysis-ik/

chmod u+x ${ESAdd}/bin/service/elasticsearch
chmod u+x ${ESAdd}/bin/service/elasticsearch32
chmod u+x ${ESAdd}/bin/service/elasticsearch64

echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf

${ESAdd}/bin/service/elasticsearch64 restart
