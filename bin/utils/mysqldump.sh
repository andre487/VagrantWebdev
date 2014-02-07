#!/bin/bash
set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
cd "$DIR/../.."
vagrant ssh -c "mysqldump -uroot -ppassword --all-databases --set-charset --complete-insert > /vagrant/runtime/mysql-dump.sql" -- -T -n
read -p "Press [Enter] key to exit..."
