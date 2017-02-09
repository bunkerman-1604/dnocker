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

#touch /etc/squid3/squid_passwd
#htpasswd /etc/squid3/squid_passwd testname
#auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid3/squid_passwd
#auth_param basic children 5 startup=5 idle=1
#auth_param basic realm Squid proxy-caching web server
#auth_param basic credentialsttl 2 hours
#acl auth_user proxy_auth sam
#http_access allow auth_user
service squid3 restart
