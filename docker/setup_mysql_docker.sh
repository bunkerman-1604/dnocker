#!/bin/bash
mysqltag=mysql:5.6.30
mypwd="zentao789&*("
if [ `docker images | grep mysql | wc -l` -eq 0 ];then
	docker pull ${mysqltag}
fi
if [ `docker ps -a | grep mysql | wc -l ` -gt 0 ];then
	docker stop mysql
	docker rm mysql
fi
docker run --name mysql -e MYSQL_ROOT_PASSWORD=${mypwd} -p 3306:3306 \
-d ${mysqltag} --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
