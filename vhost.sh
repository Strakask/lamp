#!/bin/bash

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, please use root to create vhost" && exit 1

echo "#######################################################################"
echo "#                    LNMP for CentOS/RadHat 5/6                       #"
echo "# For more information please visit http://blog.linuxeye.com/82.html  #"
echo "#######################################################################"
echo ''

while :
do
	read -p "Please input domain(example: www.linuxeye.com linuxeye.com):" domain
	if [ -z "`echo $domain | grep '.*\..*'`" ]; then
		echo -e "\033[31minput error\033[0m"
	else
		break
	fi
done
if [ ! -f "/usr/local/apache/conf/vhost/$domain.conf" ]; then
	echo "################################"
	echo "domain=$domain"
	echo "################################"
else
	echo "################################"
	echo "$domain is exist!"
	echo "################################"
	exit 1
fi

read -p "Do you want to add more domain name? (y/n)" add_more_domainame
if [ "$add_more_domainame" == 'y' ]; then
	while :
	do
		read -p "Type domainname,example(blog.linuxeye.com bbs.linuxeye.com):" moredomain
		if [ -z "`echo $moredomain | grep '.*\..*'`" ]; then
			echo -e "\033[31minput error\033[0m"
		else
			echo "################################"
			echo domain list="$moredomain"
			echo "################################"
			moredomainame=" $moredomain"
			break
		fi
	done
	sa=ServerAlias$moredomainame
fi

echo "Please input the directory for the domain:$domain :"
read -p "(Default directory: /home/wwwroot/$domain):" vhostdir
if [ -z "$vhostdir" ]; then
	vhostdir="/home/wwwroot/$domain"
fi
echo "################################"
echo Virtual Host Directory="$vhostdir"
echo "################################"

echo "################################"
read -p "Allow access_log? (y/n)" access_log
echo "################################"

if [ "$access_log" == 'n' ]; then
	al='CustomLog "/dev/null" common'
else
	al=CustomLog \"logs/${domain}-access.log common\"
	echo "################################"
	echo You access log file="/usr/local/apache/logs/${domain}-access.log"
	echo "################################"
fi


[ ! -d /usr/local/apache/conf/vhost ] && mkdir /usr/local/apache/conf/vhost

echo "Create Virtul Host directory......"
mkdir -p $vhostdir
echo "set permissions of Virtual Host directory......"
chown -R www.www $vhostdir

cat >/usr/local/apache/conf/vhost/$domain.conf<<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@$domain
    DocumentRoot "$vhostdir"
    ServerName $domain 
    $sa
    ErrorLog "logs/${domain}-error.log"
    $al
<Directory "$vhostdir">
      Options Indexes MultiViews
      AllowOverride None
      Order allow,deny
      Allow from all
</Directory>
</VirtualHost>
EOF

echo "Test Apache configure file......"
/usr/local/apache/bin/apachectl -t
echo ""
echo "Restart Apache......"
/sbin/service httpd restart

echo "#######################################################################"
echo "#                    LNMP for CentOS/RadHat 5/6                       #"
echo "# For more information please visit http://blog.linuxeye.com/82.html  #"
echo "#######################################################################"
echo ''
echo "Your domain:$domain"
echo "Directory of $domain:$vhostdir"
echo ''
echo "#######################################################################"
