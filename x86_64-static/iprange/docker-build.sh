#!/bin/sh

set -e

base=`dirname $0`
cd "$base"
echo "Running `basename $0` in $0"

LDFLAGS=-static export LDFLAGS
./configure
make
