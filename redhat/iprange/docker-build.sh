#!/bin/sh

set -e

# Build any .spec files we find

base=`dirname $0`
cd "$base"
echo "Running `basename $0` in $0"

ln -s $base/rpmbuild /root/rpmbuild
for i in *.spec
do
  echo "Building $i"
  chown root:root "$i" $base/rpmbuild/SOURCES/*
  rpmbuild -ba "$i"
done
