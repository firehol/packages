#!/bin/sh

set -e

. ./package.conf

FIREHOL_MD5=`cut -f1 -d' ' < build/firehol.md5`
IPRANGE_MD5=`cut -f1 -d' ' < build/iprange.md5`

# For each release, first architecture builds firehol and iprange.
#
# Subsequent arcitectures just build iprange. This is because firehol
# is not actually architecture-dependent, we just need a way to get
# it into a package, whereas iprange is a binary and must be compiled
# for each target.
#
# Based on the OpenWRT script.

mkdir -p build/lede-17.01
cd build/lede-17.01
rm -f build-list
rm -f outputs

while read short url sdk
do
  if [ ! -d "$short" ]
  then
    if [ ! -f "$sdk.tar.xz" ]
    then
      wget "$url/$sdk.tar.xz"
    fi
    tar xfJ "$sdk.tar.xz"
    mv "$sdk" "$short"
  fi

  if [ ! -f build-list ]
  then
    rm -rf "$short"/package/firehol
    cp -rp ../../lede/firehol "$short"/package
    sed -i -e "s;<<VER>>;$FIREHOL_VERSION;" -e "s;<<URL>>;$FIREHOL_URL;" -e "s;<<MD5>>;$FIREHOL_MD5;" "$short"/package/firehol/Makefile
  fi
  rm -rf "$short"/package/iprange
  cp -rp ../../lede/iprange "$short"/package
  sed -i -e "s;<<VER>>;$IPRANGE_VERSION;" -e "s;<<URL>>;$IPRANGE_URL;" -e "s;<<MD5>>;$IPRANGE_MD5;" "$short"/package/iprange/Makefile
  echo "$short" >> build-list
done <<!
ar71xx_generic https://downloads.lede-project.org/snapshots/targets/ar71xx/generic lede-sdk-ar71xx-generic_gcc-5.4.0_musl.Linux-x86_64
brcm47xx_generic https://downloads.lede-project.org/snapshots/targets/brcm47xx/generic lede-sdk-brcm47xx-generic_gcc-5.4.0_musl.Linux-x86_64
!

for t in `cat build-list`
do
  echo "build $t"
  cd "$t"
  # We don't want to build the kernel or modules
  make -j1 V=s defconfig
  rm -rf package/linux; touch .config
  make -j1 V=s package/compile
  cd ..
  find "$t" -name '*.ipk' -a \! -name 'lib*.ipk' >> outputs
done

while read output
do
  short=`echo $output | cut -f1 -d'/'`
  outname=`basename "$output" | sed "s:\.ipk\$:_17.01_${short}.ipk:"`
  cp "$output" "../../output/packages/$outname"
done < outputs
