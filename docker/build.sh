#!/bin/bash
if [ -f tmp ];then
        docker stop `docker ps -a`
        docker rm `docker ps -a`
        docker rmi md1
        rm -rf tmp
else
        docker build -t md1 .
#        docker build -t md1 ../mysql/5.7/
        echo "template !" >> tmp
fi
