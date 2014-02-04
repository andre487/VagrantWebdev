#!/bin/bash
set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
cd "$DIR/../../.."
vagrant ssh -c "sudo cp /var/lib/redis/dump.rdb /vagrant/runtime/redis-dump.rdb" -- -T -n
read -p "Press [Enter] key to exit..."
