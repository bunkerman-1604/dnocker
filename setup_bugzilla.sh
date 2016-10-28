#!/bin/bash
#pre-envirment
#apt-get install language-pack-zh-hans
apt-get install git nano
apt-get install apache2 mysql-server libappconfig-perl libdate-calc-perl libtemplate-perl libmime-perl build-essential libdatetime-timezone-perl libdatetime-perl libemail-sender-perl libemail-mime-perl libemail-mime-modifier-perl libdbi-perl libdbd-mysql-perl libcgi-pm-perl libmath-random-isaac-perl libmath-random-isaac-xs-perl apache2-mpm-prefork libapache2-mod-perl2 libapache2-mod-perl2-dev libchart-perl libxml-perl libxml-twig-perl perlmagick libgd-graph-perl libtemplate-plugin-gd-perl libsoap-lite-perl libhtml-scrubber-perl libjson-rpc-perl libdaemon-generic-perl libtheschwartz-perl libtest-taint-perl libauthen-radius-perl libfile-slurp-perl libencode-detect-perl libmodule-build-perl libnet-ldap-perl libauthen-sasl-perl libtemplate-perl-doc libfile-mimeinfo-perl libhtml-formattext-withlinks-perl libgd-dev lynx-cur python-sphinx

#download bugzilla
git clone --branch release-4.4-stable https://git.mozilla.org/bugzilla/bugzilla html

#configure MySQL
sed -i "max_allowed_packet/cmax_allowed_packet=100M" /etc/mysql/my.cnf
#Alter on Line 52: max_allowed_packet=100M
#Add as new line 31, in the [mysqld] section: ft_min_word_len=2
#mysql -u root -p -e "GRANT ALL PRIVILEGES ON bugs.* TO bugs@localhost IDENTIFIED BY '123456'"
service mysql restart

#configure Apache
#nano /etc/apache2/sites-available/bugzilla.conf
#ServerName localhost

#<Directory /var/www/html>
#  AddHandler cgi-script .cgi
#  Options +ExecCGI
#  DirectoryIndex index.cgi index.html
#  AllowOverride Limit FileInfo Indexes Options
#</Directory>

#restart service
2ensite bugzilla
a2enmod cgi headers expires
service apache2 restart

vi ./localconfig
Line 29: set $webservergroup to www-data
Line 67: set $db_pass 

./checksetup.pl

./testserver.pl http://localhost/


    mail_delivery_method: SMTP
    mailfrom: new_gmail_address@gmail.com
    smtpserver: smtp.gmail.com:465
    smtp_username: new_gmail_address@gmail.com
    smtp_password: new_gmail_password
    smtp_ssl: On

Click Save Changes at the bottom of the page.
