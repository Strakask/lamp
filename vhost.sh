#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

# Check if user is root
[ $(id -u) != "0" ] && { echo -e "\033[31mError: You must be root to run this script\033[0m"; exit 1; } 
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#    LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+    #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"
. ./options.conf

Input_domain()
{
while :
do
	echo
	read -p "Please input domain(example: www.linuxeye.com): " domain
	if [ -z "`echo $domain | grep '.*\..*'`" ]; then
		echo -e "\033[31minput error! \033[0m"
	else
		break
	fi
done

if [ -e "$web_install_dir/conf/vhost/$domain.conf" -o -e "$apache_install_dir/conf/vhost/$domain.conf" ]; then
	[ -e "$apache_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Apache already exist! \nYou can delete \033[32m$apache_install_dir/conf/vhost/$domain.conf\033[0m and re-create"
	exit 1
else
	echo "domain=$domain"
fi

while :
do
	echo ''
        read -p "Do you want to add more domain name? [y/n]: " moredomainame_yn 
        if [ "$moredomainame_yn" != 'y' ] && [ "$moredomainame_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break 
        fi
done

if [ "$moredomainame_yn" == 'y' ]; then
        while :
        do
                echo
                read -p "Type domainname,example(linuxeye.com www.example.com): " moredomain
                if [ -z "`echo $moredomain | grep '.*\..*'`" ]; then
                        echo -e "\033[31minput error\033[0m"
                else
			[ "$moredomain" == "$domain" ] && echo -e "\033[31mDomain name already exists! \033[0m" && continue
                        echo domain list="$moredomain"
                        moredomainame=" $moredomain"
                        break
                fi
        done
        Domain_alias=ServerAlias$moredomainame
fi

echo
echo "Please input the directory for the domain:$domain :"
read -p "(Default directory: /home/wwwroot/$domain): " vhostdir
if [ -z "$vhostdir" ]; then
        vhostdir="/home/wwwroot/$domain"
        echo -e "Virtual Host Directory=\033[32m$vhostdir\033[0m"
fi
echo
echo "Create Virtul Host directory......"
mkdir -p $vhostdir
echo "set permissions of Virtual Host directory......"
chown -R ${run_user}.$run_user $vhostdir
}

Apache_log()
{
while :
do
        echo ''
        read -p "Allow Apache access_log? [y/n]: " access_yn
        if [ "$access_yn" != 'y' ] && [ "$access_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done

if [ "$access_yn" == 'n' ]; then
        A_log='CustomLog "/dev/null" common'
else
        A_log="CustomLog \"/home/wwwlogs/${domain}_apache.log\" common"
        echo "You access log file=/home/wwwlogs/${domain}_apache.log"
fi
}

Create_apache_conf()
{
[ "`$apache_install_dir/bin/apachectl -v | awk -F'.' /version/'{print $2}'`" == '4' ] && R_TMP='Require all granted' || R_TMP=
[ ! -d $apache_install_dir/conf/vhost ] && mkdir $apache_install_dir/conf/vhost
cat > $apache_install_dir/conf/vhost/$domain.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@linuxeye.com 
    DocumentRoot "$vhostdir"
    ServerName $domain
    $Domain_alias
    ErrorLog "/home/wwwlogs/${domain}_error_apache.log"
    $A_log
<Directory "$vhostdir">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    $R_TMP
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

echo
$apache_install_dir/bin/apachectl -t
if [ $? == 0 ];then
	echo "Restart Apache......"
	/etc/init.d/httpd restart
else
	rm -rf $apache_install_dir/conf/vhost/$domain.conf
	echo -e "Create virtualhost ... \033[31m[FAILED]\033[0m"
	exit 1
fi

printf "
#######################################################################
#         LAMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #
# For more information please visit http://blog.linuxeye.com/82.html  #
#######################################################################
"
echo -e "`printf "%-32s" "Your domain:"`\033[32m$domain\033[0m"
echo -e "`printf "%-32s" "Virtualhost conf:"`\033[32m$apache_install_dir/conf/vhost/$domain.conf\033[0m"
echo -e "`printf "%-32s" "Directory of $domain:"`\033[32m$vhostdir\033[0m"
}

if [ -d "$web_install_dir" -a -d "$apache_install_dir" -a "$web_install_dir" == "$apache_install_dir" ];then
	Input_domain
	Apache_log
	Create_apache_conf
fi 
