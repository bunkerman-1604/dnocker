#!/bin/bash
redistar=redis-3.2.1.tar.gz
redispath=redis-3.2.1
if [ ! -f ${redistar} ];then
        wget http://download.redis.io/releases/redis-3.2.1.tar.gz
fi
if [ ! -d ${redispath} ];then
        echo ${redispath}
        tar -zxvf ${redistar}
fi
if [ ! -f ${redispath}/havedone ];then
        cd ${redispath}
        make
        cd ${redispath}/src
        make install
        echo "havedone" > ${redispath}/havedone
fi
if [ ! -f redis.conf ];then
        cp redis.conf ${redispath}
fi
tmp=(`ps -aux | grep redis`)
kill -s 9 ${tmp[1]}
service redis-server -&
