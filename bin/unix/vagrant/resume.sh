#!/bin/bash
set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
cd "$DIR/../../.."
vagrant resume
./bin/unix/utils/UpdateApacheVHosts.sh