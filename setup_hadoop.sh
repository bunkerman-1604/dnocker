#!/bin/bash
#############################################################
#
#hadoopmaster.wodezoon.com	=>	"localhostIPAddress"
#
#############################################################
deployedName="ClusterDeployed"
hadoopath="/home/ubuntu/hadoop-2.7.1"
jdk="/home/ubuntu/jdk1.8.0_45/"
hostIP=(`tr -sc '[0-9.]' ' ' < /home/ubuntu/hadoop/slaves`)
index=0
. /etc/profile

if [ ! -d ${hadoopath} ]; then
        tar -zxvf hadoop-2.7.1.tar.gz -C /home/ubuntu/
fi

if [ ! -f ${hadoopath}/setuped ]; then
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" 			>  ${hadoopath}/etc/hadoop/core-site.xml
	echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>"	>> ${hadoopath}/etc/hadoop/core-site.xml
	echo "<configuration>"							>> ${hadoopath}/etc/hadoop/core-site.xml
	echo "        <property>"						>> ${hadoopath}/etc/hadoop/core-site.xml
	echo "                <name>fs.defaultFS</name>"			>> ${hadoopath}/etc/hadoop/core-site.xml
	echo "                <value>hdfs://hadoopmaster.wodezoon.com:40000</value>"	>> ${hadoopath}/etc/hadoop/core-site.xml
	echo "        </property>"						>> ${hadoopath}/etc/hadoop/core-site.xml
	echo "</configuration>"							>> ${hadoopath}/etc/hadoop/core-site.xml
	echo "<?xml version=\"1.0\"?>"						>  ${hadoopath}/etc/hadoop/yarn-site.xml
	echo "<configuration>"							>> ${hadoopath}/etc/hadoop/yarn-site.xml
	echo "        <property>"						>> ${hadoopath}/etc/hadoop/yarn-site.xml
	echo "                <name>yarn.resourcemanager.hostname</name>"	>> ${hadoopath}/etc/hadoop/yarn-site.xml
	echo "                <value>hadoopmaster.wodezoon.com</value>"		>> ${hadoopath}/etc/hadoop/yarn-site.xml
	echo "        </property>"						>> ${hadoopath}/etc/hadoop/yarn-site.xml
	echo "</configuration>"							>> ${hadoopath}/etc/hadoop/yarn-site.xml
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" 			>  ${hadoopath}/etc/hadoop/hdfs-site.xml
	echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>"	>> ${hadoopath}/etc/hadoop/hdfs-site.xml
	echo "<configuration>"							>> ${hadoopath}/etc/hadoop/hdfs-site.xml
	echo "        <property>"						>> ${hadoopath}/etc/hadoop/hdfs-site.xml
	if [[ $(hostname) = hadoopm* ]]; then
		echo "                <name>dfs.namenode.name.dir</name>"	>> ${hadoopath}/etc/hadoop/hdfs-site.xml
	fi
	if [[ $(hostname) = hadoops* ]]; then
		echo "                <name>dfs.datanode.data.dir</name>"	>> ${hadoopath}/etc/hadoop/hdfs-site.xml
	fi
	echo "                <value>/home/ubuntu/hadoopdata</value>"		>> ${hadoopath}/etc/hadoop/hdfs-site.xml
	echo "        </property>"						>> ${hadoopath}/etc/hadoop/hdfs-site.xml
	echo "</configuration>"							>> ${hadoopath}/etc/hadoop/hdfs-site.xml
	sed -i "/^export JAVA_HOME=/cexport JAVA_HOME=${jdk}"			${hadoopath}/etc/hadoop/hadoop-env.sh
        echo "${hadoopath}/bin/hdfs namenode -format ${deployedName}"		>> ${hadoopath}/setuped
        ${hadoopath}/bin/hdfs namenode -format ${deployedName}
fi
for i in "${hostIP[@]}"; do
        index=$[index+1]
        if [ ${index} -eq 1 ]; then
                echo "$i        hadoopmaster.wodezoon.com"			>  /etc/hosts
        else
                echo "$i        hadoopslaver$[index-1].wodezoon.com"		>> /etc/hosts
        fi
done
if [[ $(hostname) = hadoopm* ]]; then
        echo "${hadoopath}/sbin/hadoop-daemon.sh --config ${hadoopath}/etc/hadoop/ --script hdfs stop  namenode$(date)" >> ${hadoopath}/setuped
        ${hadoopath}/sbin/hadoop-daemon.sh	 --config ${hadoopath}/etc/hadoop/ --script hdfs stop  namenode
        echo "${hadoopath}/sbin/hadoop-daemon.sh --config ${hadoopath}/etc/hadoop/ --script hdfs start namenode$(date)" >> ${hadoopath}/setuped
        ${hadoopath}/sbin/hadoop-daemon.sh	 --config ${hadoopath}/etc/hadoop/ --script hdfs start namenode
        echo "${hadoopath}/sbin/yarn-daemon.sh	 --config ${hadoopath}/etc/hadoop/ stop	 resourcemanager$(date)" >> ${hadoopath}/setuped
        ${hadoopath}/sbin/yarn-daemon.sh	 --config ${hadoopath}/etc/hadoop/ stop	 resourcemanager
        echo "${hadoopath}/sbin/yarn-daemon.sh	 --config ${hadoopath}/etc/hadoop/ start resourcemanager$(date)" >> ${hadoopath}/setuped
        ${hadoopath}/sbin/yarn-daemon.sh	 --config ${hadoopath}/etc/hadoop/ start resourcemanager
fi
if [[ $(hostname) = hadoops* ]]; then
	echo "${hadoopath}/sbin/hadoop-daemon.sh --config ${hadoopath}/etc/hadoop/ --script hdfs stop  datanode$(date)" >> ${hadoopath}/setuped
        ${hadoopath}/sbin/hadoop-daemon.sh       --config ${hadoopath}/etc/hadoop/ --script hdfs stop  datanode
        echo "${hadoopath}/sbin/hadoop-daemon.sh --config ${hadoopath}/etc/hadoop/ --script hdfs start datanode$(date)" >> ${hadoopath}/setuped
        ${hadoopath}/sbin/hadoop-daemon.sh       --config ${hadoopath}/etc/hadoop/ --script hdfs start datanode
        echo "${hadoopath}/sbin/yarn-daemon.sh   --config ${hadoopath}/etc/hadoop/ stop  nodemanager$(date)" >> ${hadoopath}/setuped
        ${hadoopath}/sbin/yarn-daemon.sh         --config ${hadoopath}/etc/hadoop/ stop  nodemanager
        echo "${hadoopath}/sbin/yarn-daemon.sh   --config ${hadoopath}/etc/hadoop/ start nodemanager$(date)" >> ${hadoopath}/setuped
        ${hadoopath}/sbin/yarn-daemon.sh         --config ${hadoopath}/etc/hadoop/ start nodemanager
fi
