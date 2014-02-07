#!/bin/bash
set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
cd "$DIR/../.."
vagrant ssh -c "sudo /usr/bin/indexer --rotate --all --config /etc/sphinxsearch/sphinx.conf" -- -T -n
read -p "Press [Enter] key to exit..."
