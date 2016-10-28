#!/bin/bash
delta=0
shards=3
datanode=3
confnode=3
logpath=/home/ubuntu/logs
datapath=/home/ubuntu/datafile
mongpath=/root/mongodb-linux-x86_64-ubuntu1404-3.0.3
mmspath=/opt/mongodb/mms/conf/conf-mms.properties
export LC_ALL=C
if [ ! -d ${mongpath} ]; then
        tar -zxvf /home/ubuntu/mongodb-linux-x86_64-ubuntu1404-3.0.3.tgz -C /root
fi
if [ ! -d ${logpath}/appdb ]; then
        mkdir -p ${logpath}/appdb
fi
if [ ! -d ${logpath}/backup ]; then
        mkdir -p ${logpath}/backup
fi
if [ ! -d ${datapath}/appdb ]; then
        mkdir -p ${datapath}/appdb
fi
if [ ! -d ${datapath}/bakup ]; then
        mkdir -p ${datapath}/bakup
fi

echo "$(hostname)" > ${mongpath}/host
tmp=`tr -sc '[0-9]' ' ' < ${mongpath}/host`
#init.js==>
echo "sh.status()" > ${mongpath}/sh.addShard.js
for ((i=1;i<=${shards};i++));do
	cfgtxt="cfg={_id : \"testers$i\",members:["
	for ((j=1;j<=${datanode};j++)) ;do
		if [ $[j/datanode] -eq 0 ] ; then
			cfgtxt="${cfgtxt}{_id : $[j-1], host : 'mongodbsharer$[i*datanode+j+delta-datanode].wodezoon.com',priority:$[datanode-j]},"
		fi
		if [ $[j/datanode] -eq 1 ] ; then
			if [ ${j} -eq 1 ] ; then
				cfgtxt="${cfgtxt}{_id : $[j-1], host : 'mongodbsharer$[i*datanode+j+delta-datanode].wodezoon.com',priority:1}]}"
			else
				cfgtxt="${cfgtxt}{_id : $[j-1], host : 'mongodbsharer$[i*datanode+j+delta-datanode].wodezoon.com',arbiterOnly:true}]}"
			fi
		fi
	done
	echo "${cfgtxt}"										>	${mongpath}/rs.initiate$[i*datanode+1+delta-datanode].js
        echo "rs.initiate(cfg)"										>>	${mongpath}/rs.initiate$[i*datanode+1+delta-datanode].js
        echo "quit()"											>>	${mongpath}/rs.initiate$[i*datanode+1+delta-datanode].js
        echo "sh.addShard(\"testers$i/mongodbsharer$[i*datanode+1+delta-datanode].wodezoon.com\")"	>>	${mongpath}/sh.addShard.js
done
echo "quit()"												>>	${mongpath}/sh.addShard.js
echo "${mongpath}/bin/mongos -fork -logpath ${logpath}/root.log -configdb \\"				>	${mongpath}/setConf.sh
for ((m=1;m<=${confnode};m++));do
	if [ $m -ne ${confnode} ] ; then
		echo "mongodbconfer$[shards*datanode+m+delta].wodezoon.com:27017,\\"			>>	${mongpath}/setConf.sh
	else
		echo "mongodbconfer$[shards*datanode+m+delta].wodezoon.com:27017 \\"			>>	${mongpath}/setConf.sh
	fi
done
echo "-port 27017"											>>	${mongpath}/setConf.sh
chmod u+x ${mongpath}/setConf.sh
#init.js==>

if [[ $(hostname) = mongodbrouter* ]]; then
	${mongpath}/setConf.sh
        tmp1=$[delta+shards*datanode+confnode+1]
        if [[ $(hostname) = mongodbrouter${tmp1}* ]]; then
		for ((n=1;n<=${shards};n++)) ; do
        		echo "${mongpath}/bin/mongo mongodbsharer$[n*datanode+1-datanode+delta].wodezoon.com --shell ${mongpath}/rs.initiate$[n*datanode+1-datanode+delta].js"
        		${mongpath}/bin/mongo mongodbsharer$[n*datanode+1-datanode+delta].wodezoon.com --shell ${mongpath}/rs.initiate$[n*datanode+1-datanode+delta].js
		done
                echo "sh.enableSharding(\"Music\")"  							>       ${mongpath}/shard.js
                echo "sh.enableSharding(\"Log\")"							>>      ${mongpath}/shard.js
                echo "sh.shardCollection(\"Music.Artist\",{\"baiduId\":1})"     			>>      ${mongpath}/shard.js
                echo "sh.shardCollection(\"Music.Song\",{\"songId\":1})"        			>>      ${mongpath}/shard.js
                echo "sh.shardCollection(\"Log.Music\",{\"date\":1})"           			>>      ${mongpath}/shard.js
                echo "sh.shardCollection(\"Log.Complete\",{\"id\":1})"          			>>      ${mongpath}/shard.js
                echo "sh.shardCollection(\"Music.fs.files\",{\"_id\":1})"       			>>      ${mongpath}/shard.js
                echo "sh.shardCollection(\"Music.fs.chunks\",{\"files_id\":1})" 			>>      ${mongpath}/shard.js
                echo "quit()"										>>      ${mongpath}/shard.js
                echo "${mongpath}/bin/mongo --shell ${mongpath}/sh.addShard.js"
                ${mongpath}/bin/mongo --shell ${mongpath}/sh.addShard.js
                echo "${mongpath}/bin/mongo --shell ${mongpath}/shard.js"
                ${mongpath}/bin/mongo --shell ${mongpath}/shard.js
        fi
fi
if [[ $(hostname) = mongodbconfer* ]]; then
        ${mongpath}/bin/mongod -fork -configsvr -dbpath ${datapath} -logpath ${logpath}/conf.log -port 27017
fi
if [[ $(hostname) = mongodbsharer* ]]; then
        tmp1=$[(tmp-1-delta)/${datanode}+1]
	echo "${mongpath}/bin/mongod -fork -dbpath ${datapath}/appdb -logpath ${logpath}/appdb/data.log -replSet testers${tmp1} -port 27017 --oplogSize 1024"
	${mongpath}/bin/mongod -fork -dbpath ${datapath}/appdb -logpath ${logpath}/appdb/data.log -replSet testers${tmp1} -port 27017 --oplogSize 1024
#        ${mongpath}/bin/mongod -fork -dbpath ${datapath}/bakup -logpath ${logpath}/bakup/data.log -replSet ${name} -port 27018
#        if [[ $(hostname) = mongodbsharer201* ]]; then
#                if [ ! -f ${mmspath} ]; then
#                        dpkg -i /home/ubuntu/mongodb-mms_1.8.0.276-1_x86_64.deb
#                fi
#                sed -i "/^mms.centralUrl=/cmms.centralUrl=http://${dbhost1}:20180" ${mmspath}
#                sed -i "/^mms.backupCentralUrl=/cmms.backupCentralUrl=http://${dbhost1}:20181" ${mmspath}
#                sed -i "/^mms.fromEmailAddr=/cmms.fromEmailAddr=qibaolai@linkgent.com" ${mmspath}
#                sed -i "/^mms.replyToEmailAddr=/cmms.replyToEmailAddr=qibaolai@linkgent.com" ${mmspath}
#                sed -i "/^mms.adminFromEmailAddr=/cmms.adminFromEmailAddr=qibaolai@linkgent.com" ${mmspath}
#                sed -i "/^mms.adminEmailAddr=/cmms.adminEmailAddr=qibaolai@linkgent.com" ${mmspath}
#                sed -i "/^mms.bounceEmailAddr=/cmms.bounceEmailAddr=qibaolai@linkgent.com" ${mmspath}
#                echo "rs.initiate()" > /home/ubuntu/init.js
#                echo "rs.conf()" >> /home/ubuntu/init.js
#                ${mongpath}/bin/mongo /home/ubuntu/init.js
#                service mongodb-mms start
#        fi
fi
#wget http://${dbhost1}:20180/download/agent/automation/mongodb-mms-automation-agent-manager_2.0.9.1201-1_amd64.deb
#wget http://${dbhost1}:20180/download/agent/monitoring/mongodb-mms-monitoring-agent_3.3.1.193-1_amd64.deb
#dpkg -i mongodb-mms-automation-agent-manager_2.0.9.1201-1_amd64.deb
#dpkg -i mongodb-mms-monitoring-agent_3.3.1.193-1_amd64.deb
#sed -i "/^mmsGroupId=/cmmsGroupId=559e2eade4b0e2f7d7d2a7b3"     /etc/mongodb-mms/automation-agent.config
#sed -i "/^mmsApiKey=/cmmsApiKey=32c8dd715ee4f9d1b8f3233f787f44ff"       /etc/mongodb-mms/automation-agent.config
#sed -i "/^mmsApiKey=/cmmsApiKey=32c8dd715ee4f9d1b8f3233f787f44ff"       /etc/mongodb-mms/monitoring-agent.config
#sed -i "/^mmsBaseUrl=/cmmsBaseUrl=http://${dbhost1}:20180"    /etc/mongodb-mms/automation-agent.config
#sed -i "/^mmsBaseUrl=/cmmsBaseUrl=http://${dbhost1}:20180"    /etc/mongodb-mms/monitoring-agent.config
#/opt/mongodb-mms-automation/bin/mongodb-mms-automation-agent -f /etc/mongodb-mms/automation-agent.config
#/opt/mongodb-mms-automation/bin/mongodb-mms-monitoring-agent -f /etc/mongodb-mms/monitoring-agent.config
if [[ $(hostname) = mongodb.wodezoon.com* ]]; then
        RockMongo_URL='https://github.com/iwind/rockmongo/archive/1.1.7.tar.gz'
        echo 'start install apache2...'
        apt-get install apache2 -y
        echo "ServerName localhost:80" >> /etc/apache2/apache2.conf
        /etc/init.d/apache2 restart
        echo 'start install php5...'
        apt-get install php5 libapache2-mod-php5 -y
        apt-get install php5-dev -y
        pecl install mongo
        echo 'extension=mongo.so' >> /etc/php5/apache2/php.ini
        /etc/init.d/apache2 restart
        wget ${RockMongo_URL} --output-document=/tmp/rockmongo.tar.gz
        tar -zxvf /tmp/rockmongo.tar.gz -C /var/www/html
        echo 'success'
fi

