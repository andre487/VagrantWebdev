#!/bin/bash
set -e


#
# Options
#
SERVER_IP=""
for arg in "$@"; do
	if [[ $arg == --server_ip=* ]]
	then
		SERVER_IP=${arg/--server_ip=/}
	fi
done

if [ $SERVER_IP == "" ]
then
	echo "Error! You must pass --server_ip=<IP>"
	exit 1
fi

echo "Using server IP $SERVER_IP"


#
#Install goods
#
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y --no-install-recommends
apt-get install -y bind9 dnsutils apache2 mysql-server mysql-client memcached php5 php-pear php5-mysql php5-memcache sqlite postgresql redis-server python-pip python-mysqldb python-imaging python-redis python-memcache git vim


#
#Configure
#
service bind9 stop
service apache2 stop
service mysql stop
service postgresql stop
service redis-server stop
service memcached stop

#Apache
a2enmod rewrite
a2enmod vhost_alias
a2ensite default
cp /vagrant/provision/data/apache2/php_patch.php /etc/apache2
cp /vagrant/provision/data/apache2/default /etc/apache2/sites-available

#MySQL
sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf

mysqld_safe --init-file=/vagrant/provision/data/mysql-init.sql &> /dev/null &
echo "Wait for MySQL..."
sleep 10s
PID=`cat /var/run/mysqld/mysqld.pid`
echo "Kill MySQL ($PID)..."
kill $PID
sleep 10s
echo "Go on"

#PostgreSQL
sed -i "s/#listen_addresses = "localhost"/listen_addresses = \"*\"/g" /etc/postgresql/9.1/main/postgresql.conf
echo "postgres:password" | /usr/sbin/chpasswd
cp /vagrant/provision/data/postgres/pg_hba.conf /etc/postgresql/9.1/main/

#Redis
sed -i "s/bind 127.0.0.1/#bind 127.0.0.1/g" /etc/redis/redis.conf

#Memcached
sed -i "s/-l 127.0.0.1/#-l 127.0.0.1/g" /etc/memcached.conf

#DNS
chattr -i /etc/resolv.conf
cp /vagrant/provision/data/bind9/db.loc /etc/bind
cp /vagrant/provision/data/bind9/named.conf.local /etc/bind
cp /vagrant/provision/data/resolv.conf /etc
sed -i "s/{{SERVER_IP}}/$SERVER_IP/g" /etc/bind/db.loc
chattr +i /etc/resolv.conf

#Vim
sed -i "s/\"syntax on/syntax on/g" /etc/vim/vimrc
sed -i "s/\"set background=dark/set background=dark/g" /etc/vim/vimrc


#
#Start services
#
service bind9 start
service apache2 start
service mysql start
service postgresql start
service redis-server start
service memcached start
