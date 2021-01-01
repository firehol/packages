#!/bin/sh

# https://twindb.com/building-rpm-on-travis-ci-in-docker-containers/
# https://lebkowski.name/docker-volumes/
#
# Clean up all existed images:
#   sudo docker rm -v $(sudo docker ps -a -q -f status=exited)

set -e

. ./package.conf

IPRANGE_MD5=`cut -f1 -d' ' < build/iprange.md5`

mkdir -p build/x86_64-static
cd build/x86_64-static

cp -rp ../../x86_64-static/*.sh .

sudo rm -rf iprange

tar xfj ../iprange-$IPRANGE_VERSION.tar.bz2
mv iprange-$IPRANGE_VERSION iprange
cp -rp ../../x86_64-static/iprange/*.sh iprange

if ! sudo docker inspect firehol-package-x86_64-static > /dev/null 2>&1
then
  # To run interactively:
  #   sudo docker run -it firehol-package-x86_64-static /bin/sh
  # (add -v host-dir:guest-dir:rw arguments to mount volumes)
  # To remove images in order to re-create:
  #   sudo docker rm -v $(sudo docker ps -a -q -f status=exited)
  #   sudo docker rmi firehol-package-x86_64-static
  sudo docker run -v `pwd`:/fh-build/x86_64-static:rw alpine:3.5 \
              /bin/sh /fh-build/x86_64-static/docker-setup.sh
  id=`sudo docker ps -l -q`
  sudo docker commit $id firehol-package-x86_64-static
 fi
sudo docker run -v `pwd`:/fh-build/x86_64-static:rw firehol-package-x86_64-static \
            /bin/sh /fh-build/x86_64-static/iprange/docker-build.sh
cd ../..

if [ "$USER" ]
then
  sudo chown -R "$USER" .
fi

# TODO: cp -p ??? output/packages
