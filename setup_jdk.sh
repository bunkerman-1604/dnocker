jdk="/home/ubuntu/jdk1.8.0_45/"
if [ ! -d ${jdk} ]; then
        tar -zxvf /home/ubuntu/jdk-8u45-linux-x64.tar.gz -C /home/ubuntu
        echo "tar -zxvf /home/ubuntu/jdk-8u45-linux-x64.tar.gz -C /home/ubuntu" >> /home/ubuntu/javad
        chmod u+x ${jdk}
fi
. /etc/profile
