#!/bin/sh

set -e

# Set up a docker image so we can perform RPM builds in it
yum install -y rpm-build make gcc automake autoconf

# FireHOL dependencies
MAJOR_VERSION=`cat /etc/redhat-release | grep -o -P '[0-9]+\.' | head -n 1 | grep -o -P '[0-9]+'`
if [ "${MAJOR_VERSION}" == "7" ]
then
	yum install -y iproute ipset iptables iptables-ipv6 tcpdump systemd zlib-devel libuuid-devel
else
	yum install -y iproute ipset iptables-services kmod tcpdump systemd zlib-devel libuuid-devel procps-ng iproute-tc
fi
