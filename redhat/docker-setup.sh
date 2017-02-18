#!/bin/sh

set -e

# Set up a docker image so we can perform RPM builds in it
yum install -y rpm-build make gcc automake autoconf

# FireHOL dependencies
yum install -y iproute ipset iptables iptables-ipv6 tcpdump systemd zlib-devel libuuid-devel
