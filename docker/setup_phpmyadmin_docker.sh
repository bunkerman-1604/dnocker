#!/bin/bash
if [ `docker images | grep phpmyadmin/phpmyadmin | wc -l` -eq 0 ];then
	docker pull phpmyadmin/phpmyadmin
fi
if [ `docker ps -a | grep myadmin | wc -l ` -gt 0 ];then
	docker stop myadmin
	docker rm myadmin
fi
docker run --name myadmin -d -e PMA_ARBITRARY=1 -p 8080:80 phpmyadmin/phpmyadmin
