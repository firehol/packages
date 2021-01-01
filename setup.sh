#!/bin/sh

set -e

. ./package.conf

mkdir -p build
cd build

if [ ! -f firehol.md5 ]
then
  wget $FIREHOL_URL/firehol-$FIREHOL_VERSION.tar.bz2
  wget -O "firehol.md5" $FIREHOL_URL/firehol-$FIREHOL_VERSION.tar.bz2.md5
fi

if [ ! -f iprange.md5 ]
then
  wget $IPRANGE_URL/iprange-$IPRANGE_VERSION.tar.bz2
  wget -O "iprange.md5" $IPRANGE_URL/iprange-$IPRANGE_VERSION.tar.bz2.md5
fi

md5sum -c firehol.md5
md5sum -c iprange.md5

cd ..
rm -rf output
mkdir -p output/packages
mkdir -p output/checksums

exit 0
