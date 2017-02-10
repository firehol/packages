#!/bin/sh

set -e

# Set up an alpine linux docker image so we can perform static builds in it
apk update
apk add --no-cache binutils make libgcc musl-dev gcc g++

# FireHOL/Netdata dependencies
apk add --no-cache ipset iptables tcpdump libuuid e2fsprogs-dev zlib-dev
