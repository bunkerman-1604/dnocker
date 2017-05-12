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

#run build a virtual network 
#docker run \
#    --name l2tp-ipsec-vpn-server \
#    --env-file ./vpn.env \
#    -p 500:500/udp \
#    -p 4500:4500/udp \
#    -v /lib/modules:/lib/modules:ro \
#    -d --privileged \
#    fcojean/l2tp-ipsec-vpn-server
#VPN_IPSEC_PSK=a_little_vpn_2017
#VPN_USER_CREDENTIAL_LIST=[{"login":"u1","password":"j1"},{"login":"u2","password":"t2"}]
#VPN_NETWORK_INTERFACE=eth0

#win7/8/10 register table setting
#REG ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f
