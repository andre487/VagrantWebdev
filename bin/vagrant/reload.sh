#!/bin/bash
set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
cd "$DIR/../.."
vagrant reload
./bin/utils/UpdateApacheVHosts.sh
