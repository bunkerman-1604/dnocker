#!/bin/bash
pipath=/root/pipework
containerID=6d8865f8f838
oldbr=eth0
net=192.168.102.
shards=3
datanode=1
confnode=1
routenod=1
delta=0
echo "choose 1 for create container; 2 for start container;"
read choose
for ((i=1;i<=$[datanode*shards+confnode+routenod];i++));do
        cIP=$[i+87]
        sharedpath=/data/share$[i+delta]
        containerN="mongodbsharer"
        if [ ${i} -ge $[datanode*shards+1] ]; then
                containerN="mongodbconfer"
        fi
        if [ ${i} -ge $[datanode*shards+confnode+1] ]; then
                containerN="mongodbrouter"
        fi
        cName=$[i+delta]
        containerIP="${net}${cIP}"
        containerName="${containerN}${cName}.wodezoon.com"

        if [ ${choose} -eq 1 ] ; then
                echo "docker run -itd --name ${containerName} --net=none -h ${containerName} -v ${sharedpath}:/home/ubuntu ${containerID} /usr/sbin/sshd -D"
                docker run -itd --name ${containerName} --net=none -h ${containerName} -v ${sharedpath}:/home/ubuntu ${containerID} /usr/sbin/sshd -D
        fi

        if [ ${choose} -eq 2 ] ; then
                if [ $i -eq 1 ] ; then
                        echo "docker start `docker ps -a`"
                        docker start `docker ps -a`
                fi
        fi

        echo "${pipath}/pipework ${oldbr} ${containerName} ${containerIP}/24@${net}1"
        ${pipath}/pipework ${oldbr} ${containerName} ${containerIP}/24@${net}1
done
