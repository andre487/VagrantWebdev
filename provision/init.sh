#!/bin/bash

set -e


#
#Apt operations
#
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y --no-install-recommends
apt-get install -y bind9 dnsutils apache2 php5 mysql-server mysql-client php5 php-pear php5-mysql sqlite postgresql python-pip python-mysqldb python-imaging vim


#
#Configure
#
service bind9 stop
service apache2 stop
service mysql stop

#Apache
a2enmod rewrite
a2enmod vhost_alias
a2ensite default
cp /vagrant/provision/data/apache2/default /etc/apache2/sites-available

#MySQL
sed -i 's/bind-address/#bind-address/g' /etc/mysql/my.cnf

mysqld_safe --init-file=/vagrant/provision/data/mysql-init.sql &> /dev/null &
echo "Wait for MySQL..."
sleep 10s
PID=`cat /var/run/mysqld/mysqld.pid`
echo "Kill MySQL ($PID)..."
kill $PID
sleep 10s
echo "Go on"

#DNS
cp /vagrant/provision/data/bind9/db.loc /etc/bind
cp /vagrant/provision/data/bind9/named.conf.local /etc/bind
cp /vagrant/provision/data/resolv.conf /etc
chattr +i /etc/resolv.conf


#
#Start services
#
service bind9 start
service apache2 start
service mysql start
