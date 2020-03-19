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

osver=19.07
mkdir -p build/openwrt-$osver
cd build/openwrt-$osver
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
    cp -rp ../../openwrt/firehol "$short"/package
    sed -i -e "s;<<VER>>;$FIREHOL_VERSION;" -e "s;<<URL>>;$FIREHOL_URL;" -e "s;<<MD5>>;$FIREHOL_MD5;" "$short"/package/firehol/Makefile
  fi
  rm -rf "$short"/package/iprange
  cp -rp ../../openwrt/iprange "$short"/package
  sed -i -e "s;<<VER>>;$IPRANGE_VERSION;" -e "s;<<URL>>;$IPRANGE_URL;" -e "s;<<MD5>>;$IPRANGE_MD5;" "$short"/package/iprange/Makefile
  echo "$short" >> build-list
done <<!
ar71xx_generic https://downloads.openwrt.org/releases/19.07.2/targets/ar71xx/generic openwrt-sdk-19.07.2-ar71xx-generic_gcc-7.5.0_musl.Linux-x86_64
brcm47xx_generic https://downloads.openwrt.org/releases/19.07.2/targets/brcm47xx/generic openwrt-sdk-19.07.2-brcm47xx-generic_gcc-7.5.0_musl.Linux-x86_64
ipq806x_generic https://downloads.openwrt.org/releases/19.07.2/targets/ipq806x/generic openwrt-sdk-19.07.2-ipq806x-generic_gcc-7.5.0_musl_eabi.Linux-x86_64
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
  base=`basename "$output"`
  case "$base" in
    firehol*)
       outname=`echo "$base" | sed "s:\.ipk\$:_${osver}_all.ipk:"`
    ;;
    *)
       outname=`echo "$base" | sed "s:\.ipk\$:_${osver}_${short}.ipk:"`
    ;;
  esac
  cp "$output" "../../output/packages/$outname"
done < outputs
