#/bin/bash
AllowIP=211.103.222.254-211.103.222.254/24
apt-get install squid
if [ ! -f /etc/squid3/squid.conf.bak ];then
        cp /etc/squid3/squid.conf /etc/squid3/squid.conf.bak
else
        cp /etc/squid3/squid.conf.bak /etc/squid3/squid.conf
fi
sed -i "/^acl CONNECT/,+0aacl AllowIP src ${AllowIP}"            /etc/squid3/squid.conf
ed -i "/^http_access deny all/c#http_access deny all"            /etc/squid3/squid.conf
sed -i "/^#http_access deny all/,+0a http_access allow all"       /etc/squid3/squid.conf
service squid3 restart
