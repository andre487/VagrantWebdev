#!/bin/bash
set -e


#
# Options
#
SERVER_IP=""
for arg in "$@"; do
    if [[ ${arg} == --server_ip=* ]]
    then
        SERVER_IP=${arg/--server_ip=/}
    fi
done

if [ ${SERVER_IP} == "" ]
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
apt-get install -y apache2 libapache2-mod-macro \
 php5 php-pear php5-mysql php5-memcache \
 python-pip python-mysqldb python-imaging python-redis python-memcache python-sphinx \
 mysql-server mysql-client memcached \
 sqlite postgresql sphinxsearch redis-server \
 git vim

pear config-set auto_discover 1
pear install pear.phpunit.de/PHPUnit phpunit/DbUnit


#
#Configure
#
service apache2 stop
service mysql stop
service postgresql stop
service redis-server stop
service memcached stop
service sphinxsearch stop
service exim4 stop

#Apache
a2enmod rewrite
a2enmod macro
a2ensite default
cp /vagrant/provision/data/apache2/default /etc/apache2/sites-available
/vagrant/bin/internal/update-apache-vhosts


#MySQL
sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf

mysqld_safe --init-file=/vagrant/provision/data/mysql-init.sql &> /dev/null &
echo "Waiting for the MySQL init..."
sleep 10s
PID=`cat /var/run/mysqld/mysqld.pid`
echo "Killing the MySQL ($PID)..."
kill ${PID}
sleep 10s
echo "Go on"

#PostgreSQL
sed -i "s/#listen_addresses = "localhost"/listen_addresses = \"*\"/g" /etc/postgresql/9.1/main/postgresql.conf
echo "postgres:password" | /usr/sbin/chpasswd
cp /vagrant/provision/data/postgres/pg_hba.conf /etc/postgresql/9.1/main/
cp /vagrant/provision/data/.pgpass /home/vagrant
chmod 600 /home/vagrant/.pgpass

#Redis
sed -i "s/bind 127.0.0.1/#bind 127.0.0.1/g" /etc/redis/redis.conf

#Memcached
sed -i "s/-l 127.0.0.1/#-l 127.0.0.1/g" /etc/memcached.conf

#Sphinx
cp /vagrant/provision/data/sphinxsearch /etc -R
chmod +x /etc/sphinxsearch/sphinx.conf

#Exin4
cp /vagrant/provision/data/update-exim4.conf.conf /etc/exim4

#Vim
sed -i "s/\"syntax on/syntax on/g" /etc/vim/vimrc
sed -i "s/\"set background=dark/set background=dark/g" /etc/vim/vimrc


#
#Start services
#
service apache2 start
service mysql start
service postgresql start
service redis-server start
service memcached start
service sphinxsearch start
service exim4 start
