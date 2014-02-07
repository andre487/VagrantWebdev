#!/bin/bash
set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
cd "$DIR/../.."
vagrant ssh -c "sudo /vagrant/bin/internal/update-apache-vhosts" -- -T -n
