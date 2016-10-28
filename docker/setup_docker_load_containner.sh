#wget -qO- https://get.docker.com/ | sh                 #
#                                                       #
#import export.tar                                      #
#cat /home/export.tar | docker import - targit:latest   #
#                                                       #
#setup_pipework                                         #
#git clone https://github.com/jpetazzo/pipework         #
#########################################################

##############Parameters to be set up####################
tag=0
tmp=(`cat setup_docker_load_containner.sh | grep 'tag=' | cut -b 5-`)
index=$[ tmp[0] + 1 ]
sed -i "/^tag=/ctag=${index}" setup_docker_load_containner.sh
containerID=md1
sharedpath=/data/share${index}
containerName=mydocker${index}
hostIP=(`ifconfig eth0 | grep "inet " | tr -sc '[0-9.]' ' '`)
containerIP=${hostIP%.*}.${index+128}
gatewayIP=${hostIP%.*}.1
pipath=/home/sam/pipework
desbr=eth
oldbr=eth
#########################################################
echo "please choose container build mode--1:NAT;2:Bridge;3:SetupPipwork;"
read nettype
if [ ${nettype} -eq 1 ]; then
docker run -itd --name ${containerName} \
-p ${hostIP}:${index+100}22:22 \
-h ${containerName} \
-v ${sharedpath}:/home/ubuntu \
${containerID} /bin/bash -D
fi
if [ ${nettype} -eq 2 ]; then
docker run -itd --name ${containerName} --net=none \
-h ${containerName} \
-v ${sharedpath}:/home/ubuntu \
${containerID} /usr/sbin/sshd -D
${pipath}/pipework ${desbr} ${containerName} ${containerIP}/24@${gatewayIP}
docker exec -itd ${containerName} /etc/init.d/mysql restart
fi
if [ ${nettype} -eq 3 ]; then
apt-get install bridge-utils
ip addr del ${hostIP}/24 dev ${oldbr}; \
ip addr add ${hostIP}/24 dev ${desbr}; \
brctl addif ${desbr} ${oldbr}; \
route del default; \
route add default gw ${gatewayIP} dev ${desbr}
fi
###############Some pattern for [docker run]#############
#${containerID} /bin/bash                               #
#                                                       #
#docker for port/memory/volume share                    #
#-m 2000m \                                             #
#########################################################
