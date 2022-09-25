#!/bin/sh

# https://twindb.com/building-rpm-on-travis-ci-in-docker-containers/
# https://lebkowski.name/docker-volumes/
#
# Clean up all existed images:
#   sudo docker rm -v $(sudo docker ps -a -q -f status=exited)

set -e

update_docker_image=""
if [ "$1" = "-u" ]
then
  update_docker_image="Y"
  shift
fi

. ./package.conf

FIREHOL_MD5=`cut -f1 -d' ' < build/firehol.md5`
IPRANGE_MD5=`cut -f1 -d' ' < build/iprange.md5`

for v in 8 9
do
  mkdir -p build/el${v}
  cd build/el${v}

  sudo rm -rf firehol/rpmbuild iprange/rpmbuild
  rm -rf firehol iprange
  cp -rp ../../redhat/*.sh .
  cp -rp ../../redhat/firehol .
  cp -rp ../../redhat/iprange .

  mkdir -p firehol/rpmbuild/SOURCES
  mkdir -p iprange/rpmbuild/SOURCES

  cp ../firehol-$FIREHOL_VERSION.tar.bz2 firehol/rpmbuild/SOURCES
  cp firehol/*.service firehol/rpmbuild/SOURCES
  cp firehol/*.init firehol/rpmbuild/SOURCES
  cp ../iprange-$IPRANGE_VERSION.tar.bz2 iprange/rpmbuild/SOURCES

  sed -i -e "s;<<VER>>;$FIREHOL_VERSION;" -e "s;<<URL>>;$FIREHOL_URL;" -e "s;<<MD5>>;$FIREHOL_MD5;" -e "/Release:/s/%.*/$RPM_FIREHOL_RELEASE%{?dist}/" firehol/firehol.spec
  tar xfj ../iprange-$IPRANGE_VERSION.tar.bz2 iprange-$IPRANGE_VERSION/iprange.spec
  mv iprange-$IPRANGE_VERSION/iprange.spec iprange/iprange.spec
  rmdir iprange-$IPRANGE_VERSION
  sed -i -e "s;_sbindir;_bindir;" -e '/^%files/a\
%{_mandir}/man1/iprange.1.gz' -e "/Release:/s/%.*/$RPM_IPRANGE_RELEASE%{?dist}/" -e "/BuildRoot:/d" iprange/iprange.spec

  if ! sudo docker inspect firehol-package-centos${v} > /dev/null 2>&1
  then
    # To remove in order to re-create entirely:
    #   sudo docker rm -v $(sudo docker ps -a -q -f status=exited)
    #   sudo docker rmi firehol-package-centos6
    #   sudo docker rmi firehol-package-centos7
    BASE_IMAGE_NAME="centos:centos{$v}"
    if [ "${v}" != "7" ]
    then
      BASE_IMAGE_NAME="rockylinux:${v}"
    fi
    sudo docker run -v `pwd`:/fh-build/centos${v}:rw ${BASE_IMAGE_NAME} \
                /bin/bash /fh-build/centos${v}/docker-setup.sh
    id=`sudo docker ps -l -q`
    sudo docker commit $id firehol-package-centos${v}
  elif [ "$update_docker_image" ] # e.g. to add new dependencies
  then
    sudo docker run -v `pwd`:/fh-build/centos${v}:rw \
                firehol-package-centos${v} \
                /bin/bash /fh-build/centos${v}/docker-setup.sh
    id=`sudo docker ps -l -q`
    sudo docker commit $id firehol-package-centos${v}-new
    sudo docker rm -v $(sudo docker ps -a -q -f status=exited) > /dev/null
    sudo docker rmi firehol-package-centos${v}
    sudo docker tag firehol-package-centos${v}-new firehol-package-centos${v}
    sudo docker rmi firehol-package-centos${v}-new
  fi
  sudo docker run -v `pwd`:/fh-build/centos${v}:rw firehol-package-centos${v} \
              /bin/bash /fh-build/centos${v}/iprange/docker-build.sh
  sudo docker run -v `pwd`:/fh-build/centos${v}:rw firehol-package-centos${v} \
              /bin/bash -c "yum install -y /fh-build/centos${v}/iprange/rpmbuild/RPMS/x86_64/iprange-$IPRANGE_VERSION-$RPM_IPRANGE_RELEASE.el${v}.x86_64.rpm && /bin/bash /fh-build/centos${v}/firehol/docker-build.sh"
  cd ../..
done

if [ "$USER" ]
then
  sudo chown -R "$USER" .
fi

find build/*/*/rpmbuild -name '*.rpm' -exec cp -p \{\} output/packages \;
rm -f output/packages/*-debuginfo-*
