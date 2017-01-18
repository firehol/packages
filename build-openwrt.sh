#!/bin/sh

set -e

. ./package.conf

FIREHOL_MD5=`cut -f1 -d' ' < build/firehol.md5`
IPRANGE_MD5=`cut -f1 -d' ' < build/iprange.md5`

# For each release, first architecture builds firehol # and iprange.
#
# Subsequent arcitectures just build iprange. This is because firehol
# is not actually architecture-dependent, we just need a way to get
# it into a package, whereas iprange is a binary and must be compiled
# for each target.
#
# General docs:
#   https://wiki.openwrt.org/doc/devel/packages
#   https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
#
# Once we have an SDK with the package dropped-in, at the top level
# we can run the following:
#   make
#   make -j1 V=s
#   make package/firehol/clean V=99
#   make package/firehol/prepare V=99
#   make package/firehol/configure V=99
#   make package/firehol/compile V=99
#   make package/firehol/install V=99

mkdir -p build/chaos_calmer
cd build/chaos_calmer
rm -f build-list

while read short url sdk
do
  if [ ! -d "$short" ]
  then
    wget "$url/$sdk.tar.bz2"
    tar xfj "$sdk.tar.bz2"
    mv "$sdk" "$short"
  fi

  if [ ! -f build-list ]
  then
    rm -rf "$short"/package/firehol
    cp -rp ../../openwrt/firehol "$short"/package
    sed -i -e "s;<<VER>>;$FIREHOL_VERSION;" -e "s;<<URL>>;$FIREHOL_URL;" -e "s;<<MD5>>;$FIREHOL_MD5;" "$short"/package/firehol/Makefile
  fi
  rm -rf "$short"/package/iprange
  cp -rp ../../openwrt/iprange "$short"/package
  sed -i -e "s;<<VER>>;$IPRANGE_VERSION;" -e "s;<<URL>>;$IPRANGE_URL;" -e "s;<<MD5>>;$IPRANGE_MD5;" "$short"/package/iprange/Makefile
  echo "$short" >> build-list
done <<!
ar71xx_generic https://downloads.openwrt.org/chaos_calmer/15.05.1/ar71xx/generic OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64
brcm47xx_generic https://downloads.openwrt.org/chaos_calmer/15.05.1/brcm47xx/generic OpenWrt-SDK-15.05.1-brcm47xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64
!

while read target
do
  cd "$target"
  make -j1 V=s
  cd ..
  find "$target" -name '*.ipk' >> outputs
done < build-list

while read output
do
  outname=`basename "$output" | sed "s:\.ipk\$:_chaos_calmer.ipk:"`
  cp "$output" "../../output/packages/$outname"
done < outputs
