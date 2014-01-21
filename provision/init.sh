#!/bin/bash

set -e

#Apt operations
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y --no-install-recommends
apt-get install -y dnsmasq nginx apache2 php5 mysql-server mysql-client php5 php-pear php5-mysql sqlite postgresql python-pip python-mysqldb python-imaging

#Configure
service dnsmasq stop
service nginx stop
service apache2 stop
service mysql stop

a2enmod rewrite
a2ensite default

mysqld_safe --init-file=/vagrant/provision/data/mysql-init.sql &> /dev/null &
echo "Wait for MySQL..."
sleep 10s
PID=`cat /var/run/mysqld/mysqld.pid`
echo "Kill MySQL ($PID)..."
kill $PID
sleep 10s
echo "Go on"

#Reboot
service dnsmasq start
service nginx start
service apache2 start
service mysql start
