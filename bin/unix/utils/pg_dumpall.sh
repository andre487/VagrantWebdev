#!/bin/bash
set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
cd "$DIR/../../.."
vagrant ssh -c "pg_dumpall -hlocalhost -Upostgres > /vagrant/runtime/postgresql-dump.sql" -- -T -n
read -p "Press [Enter] key to exit..."
