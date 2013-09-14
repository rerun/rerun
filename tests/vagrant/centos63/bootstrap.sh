#!/usr/bin/env bash

set -e
yum -y install curl unzip nc autoconf automake zip rpm-build git-all

mkdir -p /var/builds
cd /var/builds

git clone https://github.com/rerun/rerun.git
cd rerun
./setup.sh

make install

make rpm

echo "done"
