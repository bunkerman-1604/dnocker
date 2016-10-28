#!/bin/bash
apppath=/root/tomcat/solr
conpath=/root/tomcat/conf
tomcat="tomcat:7-jre7-alpine"
if [ `docker images | grep tomcat | wc -l` -eq 0 ];then
	docker pull ${tomcat}
fi
if [ `docker ps -a | grep tomcat | wc -l ` -gt 0 ];then
	docker stop tomcat
	docker rm tomcat
fi
docker run --name tomcat -itd \
-v ${apppath%/*}:/opt \
-v ${conpath}:/usr/local/tomcat/conf \
-p 8080:8080 ${tomcat}
