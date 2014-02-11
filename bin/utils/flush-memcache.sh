#!/bin/bash
set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
cd "$DIR/../.."
vagrant ssh -c "/vagrant/bin/internal/flush-memcache" -- -T -n
read -p "Press [Enter] key to exit..."
