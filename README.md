This script is free collection of shell scripts for rapid deployment of `LAMP` stacks (`Linux`, `Apache`, `MySQL`/`MariaDB`/`Percona` and `PHP`) for CentOS/Redhat Debian and Ubuntu.

Script features: 
- Continually updated
- Source compiler installation, most stable source is the latest version, and download from the official site
- Some security optimization
- Providing a plurality of database versions (MySQL-5.6, MySQL-5.5, MariaDB-10.0, MariaDB-5.5, Percona-5.6, Percona-5.5)
- Providing multiple PHP versions (php-5.3, php-5.4, php-5.5, php-5.6, php-7/phpng(RC))
- Providing a plurality of Apache version (Apache-2.4, Apache-2.2)
- According to their needs to install PHP Cache Accelerator provides ZendOPcache, xcache, apcu, eAccelerator. And php encryption and decryption tool ionCube, ZendGuardLoader
- Installation Pureftpd, phpMyAdmin according to their needs
- Install memcached, redis according to their needs
- Tcmalloc can use according to their needs or jemalloc optimize MySQL, Nginx
- Providing add a virtual host script
- Provide MySQL/MariaDB/Percona, PHP, Redis, phpMyAdmin upgrade script
- Provide local backup and remote backup (rsync between servers) script

## How to use 

```bash
   yum -y install wget screen # for CentOS/Redhat
   #apt-get -y install wget screen # for Debian/Ubuntu 
   wget http://mirrors.linuxeye.com/lamp.tar.gz
   tar xzf lamp.tar.gz
   cd lamp
   # Prevent interrupt the installation process. If the network is down, 
   # you can execute commands `screen -r lamp` network reconnect the installation window.
   screen -S lamp
   ./install.sh
```

## How to add a virtual host

```bash
./vhost.sh
```

## How to add FTP virtual user 

```bash
./pureftpd_vhost.sh
```

## How to backup

```bash
./backup_setup.sh # Set backup options 
./backup.sh # Start backup, You can add cron jobs
crontab -l # Examples 
  0 1 * * * cd ~/lamp;./backup.sh  > /dev/null 2>&1 &
```

## How to manage service
MySQL/MariaDB/Percona:
```bash
   service mysqld {start|stop|restart|reload|status}
```
Apache:
```bash
service httpd {start|restart|stop}
```
Pure-Ftpd:
```bash
service pureftpd {start|stop|restart|status}
```
Redis:
```bash
service redis-server {start|stop|status|restart|reload}
```
Memcached:
```bash
service memcached {start|stop|status|restart|reload}
```

## How to upgrade 
```bash
./upgrade.sh
```

## How to uninstall 

```bash
./uninstall.sh
```

## Installation
For feedback, questions, and to follow the progress of the project (Chinese): <br />
[lamp最新源码一键安装脚本](http://blog.linuxeye.com/82.html)<br />
