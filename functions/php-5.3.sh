#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_PHP-5-3()
{
cd $lamp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$libiconv_version.tar.gz && Download_src
src_url=http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/$libmcrypt_version/libmcrypt-$libmcrypt_version.tar.gz && Download_src
src_url=http://downloads.sourceforge.net/project/mhash/mhash/$mhash_version/mhash-$mhash_version.tar.gz && Download_src
src_url=http://downloads.sourceforge.net/project/mcrypt/MCrypt/$mcrypt_version/mcrypt-$mcrypt_version.tar.gz && Download_src
src_url=http://www.php.net/distributions/php-$php_3_version.tar.gz && Download_src
src_url=http://mirrors.linuxeye.com/lnmp/src/php5.3patch && Download_src

tar xzf libiconv-$libiconv_version.tar.gz
cd libiconv-$libiconv_version
./configure --prefix=/usr/local
[ -n "`cat /etc/issue | grep 'Ubuntu 13'`" ] && sed -i 's@_GL_WARN_ON_USE (gets@//_GL_WARN_ON_USE (gets@' srclib/stdio.h 
[ -n "`cat /etc/issue | grep 'Ubuntu 14'`" ] && sed -i 's@gets is a security@@' srclib/stdio.h 
make && make install
cd ../
/bin/rm -rf libiconv-$libiconv_version

tar xzf libmcrypt-$libmcrypt_version.tar.gz
cd libmcrypt-$libmcrypt_version
./configure
make && make install
ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../
/bin/rm -rf libmcrypt-$libmcrypt_version

tar xzf mhash-$mhash_version.tar.gz
cd mhash-$mhash_version
./configure
make && make install
cd ../
/bin/rm -rf mhash-$mhash_version 

echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig
OS_CentOS='ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config \n
if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then \n
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1 \n
else \n
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1 \n
fi'
OS_command

tar xzf mcrypt-$mcrypt_version.tar.gz
cd mcrypt-$mcrypt_version
ldconfig
./configure
make && make install
cd ../
/bin/rm -rf mcrypt-$mcrypt_version 

tar xzf php-$php_3_version.tar.gz
id -u $run_user >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user 
wget -O fpm-race-condition.patch 'https://bugs.php.net/patch-display.php?bug_id=65398&patch=fpm-race-condition.patch&revision=1375772074&download=1'
patch -d php-$php_3_version -p0 < fpm-race-condition.patch
cd php-$php_3_version
patch -p1 < ../php5.3patch 
make clean
[ ! -d "$php_install_dir" ] && mkdir -p $php_install_dir
if [ "$Apache_version" == '1' -o "$Apache_version" == '2' ];then
CFLAGS= CXXFLAGS= ./configure --prefix=$php_install_dir --with-config-file-path=$php_install_dir/etc \
--with-apxs2=$apache_install_dir/bin/apxs --disable-fileinfo \
--with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
--with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
--with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
--enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex \
--enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
--with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp \
--with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
else
CFLAGS= CXXFLAGS= ./configure --prefix=$php_install_dir --with-config-file-path=$php_install_dir/etc \
--with-fpm-user=$run_user --with-fpm-group=$run_user --enable-fpm --disable-fileinfo \
--with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
--with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
--with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
--enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex \
--enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
--with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp \
--with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
fi
make ZEND_EXTRA_LIBS='-liconv'
make install

if [ -d "$php_install_dir/bin" ];then
        echo -e "\033[32mPHP install successfully! \033[0m"
else
	rm -rf $php_install_dir
        echo -e "\033[31mPHP install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi

[ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$php_install_dir/bin:\$PATH" >> /etc/profile 
[ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $php_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$php_install_dir/bin:\1@" /etc/profile
. /etc/profile

# wget -c http://pear.php.net/go-pear.phar
# $php_install_dir/bin/php go-pear.phar

/bin/cp php.ini-production $php_install_dir/etc/php.ini

# Modify php.ini
Mem=`free -m | awk '/Mem:/{print $2}'`
if [ $Mem -gt 1024 -a $Mem -le 1500 ];then
        Memory_limit=192
elif [ $Mem -gt 1500 -a $Mem -le 3500 ];then
        Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
        Memory_limit=320
elif [ $Mem -gt 4500 ];then
        Memory_limit=448
else
        Memory_limit=128
fi
sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" $php_install_dir/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' $php_install_dir/etc/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' $php_install_dir/etc/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' $php_install_dir/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' $php_install_dir/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' $php_install_dir/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $php_install_dir/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 50M@' $php_install_dir/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' $php_install_dir/etc/php.ini
sed -i 's@^;upload_tmp_dir.*@upload_tmp_dir = /tmp@' $php_install_dir/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 5@' $php_install_dir/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' $php_install_dir/etc/php.ini
sed -i 's@^session.cookie_httponly.*@session.cookie_httponly = 1@' $php_install_dir/etc/php.ini
sed -i 's@^mysqlnd.collect_memory_statistics.*@mysqlnd.collect_memory_statistics = On@' $php_install_dir/etc/php.ini
[ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' $php_install_dir/etc/php.ini

if [ "$Apache_version" == '1' -o "$Apache_version" == '2' ];then
	service httpd restart
fi
cd ..
[ -d "$php_install_dir" ] && /bin/rm -rf php-$php_3_version 
cd ..
}
