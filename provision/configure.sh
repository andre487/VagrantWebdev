#!/bin/bash
set -e


#
# Options
#
SERVER_IP=""

USE_SMTP=""
SMTP_HOST=""
SMTP_PORT=""
SMTP_USER=""
SMTP_PASSWORD=""
SMTP_SENDER=""

for arg in "$@"; do
    if [[ ${arg} == --server_ip=* ]]; then
        SERVER_IP=${arg/--server_ip=/}
    fi

    if [[ ${arg} == --use_smtp=* ]]; then
        USE_SMTP=${arg/--use_smtp=/}
    fi

    if [[ ${arg} == --smtp_host=* ]]; then
        SMTP_HOST=${arg/--smtp_host=/}
    fi

    if [[ ${arg} == --smtp_port=* ]]; then
        SMTP_PORT=${arg/--smtp_port=/}
    fi

    if [[ ${arg} == --smtp_user=* ]]; then
        SMTP_USER=${arg/--smtp_user=/}
    fi

    if [[ ${arg} == --smtp_password=* ]]; then
        SMTP_PASSWORD=${arg/--smtp_password=/}
    fi

    if [[ ${arg} == --smtp_sender=* ]]; then
        SMTP_SENDER=${arg/--smtp_sender=/}
    fi
done

if [ "$SERVER_IP" == "" ]; then
    SERVER_IP=192.168.2.10
fi

echo "Using server IP $SERVER_IP"


#
# Install goods
#
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y --no-install-recommends
apt-get install -y dnsmasq exim4 \
    apache2 libapache2-mod-macro \
    php5 php-pear php5-dev php5-mysql php5-pgsql php5-sqlite php5-memcache \
    php5-gd php5-xdebug php5-curl php5-mcrypt \
    python-mysqldb python-pygresql python-psycopg2 python-sqlite python-redis python-memcache \
    python-pip python-imaging \
    mysql-server mysql-client memcached \
    sqlite sqlite3 postgresql sphinxsearch redis-server \
    git vim

# Installations from the PEAR, PECL and PyPI; if some of this brings errors, just remove it
pear config-set auto_discover 1
pear install pear.phpunit.de/PHPUnit phpunit/DbUnit

pip install sphinxsearch

if [[ `pecl list 2>/dev/null | grep redis` == "" ]]; then
    pecl install redis
    cp /vagrant/provision/data/php/redis.ini /etc/php5/conf.d/20-redis.ini
fi


#
# Configure
#
service dnsmasq stop
service apache2 stop
service mysql stop
service postgresql stop
service redis-server stop
service memcached stop
service sphinxsearch stop
service exim4 stop

#Dnsmasq
cp /vagrant/provision/data/dnsmasq.d/vhosts.conf /etc/dnsmasq.d

# Apache
a2enmod rewrite
a2enmod macro
a2ensite default
cp /vagrant/provision/data/apache2/default /etc/apache2/sites-available
/vagrant/bin/internal/update-apache-vhosts

# PHP
if [ ! -d /vagrant/runtime/xdebug ]; then
    mkdir /vagrant/runtime/xdebug
    chmod 777 /vagrant/runtime/xdebug
fi
cp /vagrant/provision/data/php/xdebug.ini /etc/php5/conf.d/99-xdebug.ini

sed -i "s/display_errors = Off/display_errors = On/g" /etc/php5/apache2/php.ini
sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php5/apache2/php.ini
sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/g" /etc/php5/apache2/php.ini

# MySQL
sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf

mysqld_safe --init-file=/vagrant/provision/data/mysql-init.sql &> /dev/null &
echo "Waiting for the MySQL init..."
sleep 10s
PID=`cat /var/run/mysqld/mysqld.pid`
echo "Killing the MySQL ($PID)..."
kill ${PID}
sleep 10s
echo "Go on"

# PostgreSQL
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.1/main/postgresql.conf
echo "postgres:password" | /usr/sbin/chpasswd
cp /vagrant/provision/data/postgres/pg_hba.conf /etc/postgresql/9.1/main/
cp /vagrant/provision/data/.pgpass /home/vagrant
chmod 600 /home/vagrant/.pgpass

# Redis
sed -i "s/bind 127.0.0.1/#bind 127.0.0.1/g" /etc/redis/redis.conf

# Memcached
sed -i "s/-l 127.0.0.1/#-l 127.0.0.1/g" /etc/memcached.conf

# Sphinx
cp /vagrant/provision/data/sphinxsearch /etc -R
chmod +x /etc/sphinxsearch/sphinx.conf
sed -i "s/START=no/START=yes/g" /etc/default/sphinxsearch


# Exim4
if [[ "$USE_SMTP" == "1" && "$SMTP_HOST" && "$SMTP_PORT" && "$SMTP_USER" && "$SMTP_PASSWORD" && "$SMTP_SENDER" ]]; then
    echo "Exim4 mode is satelite"
    echo "Using smtp host $SMTP_HOST"
    echo "Using smtp port $SMTP_PORT"
    echo "Using smtp user $SMTP_USER"
    echo "Using smtp password $SMTP_PASSWORD"
    echo "Using smtp sender $SMTP_SENDER"

    cp /vagrant/provision/data/exim4/satelite/* /etc/exim4

    sed -i "s/{{host}}/$SMTP_HOST/g" /etc/exim4/update-exim4.conf.conf
    sed -i "s/{{port}}/$SMTP_PORT/g" /etc/exim4/update-exim4.conf.conf
    sed -i "s/{{host}}/$SMTP_HOST/g" /etc/exim4/passwd.client
    sed -i "s/{{user}}/$SMTP_USER/g" /etc/exim4/passwd.client
    sed -i "s/{{password}}/$SMTP_PASSWORD/g" /etc/exim4/passwd.client

    echo "root: $SMTP_SENDER" > /etc/email-addresses
    echo "vagrant: $SMTP_SENDER" >> /etc/email-addresses
else
    echo "Exim4 mode is local"
    cp /vagrant/provision/data/exim4/local/* /etc/exim4
    echo "" > /etc/email-addresses
fi

# Vim
sed -i "s/\"syntax on/syntax on/g" /etc/vim/vimrc
sed -i "s/\"set background=dark/set background=dark/g" /etc/vim/vimrc


#
# Start services
#
service dnsmasq start
service apache2 start
service mysql start
service postgresql start
service redis-server start
service memcached start
service sphinxsearch start
service exim4 start

#
# After configuring
#
/usr/bin/indexer --rotate --all --config /etc/sphinxsearch/sphinx.conf
