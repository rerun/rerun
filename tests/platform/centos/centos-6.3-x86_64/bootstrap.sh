#!/usr/bin/env bash

set -e
yum -y install curl unzip nc autoconf automake zip rpm-build git-all

cd /tmp
git clone https://github.com/rerun/roundup.git

cd roundup
./configure --prefix=/usr
make
make install

which roundup
