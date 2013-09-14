#!/usr/bin/env bash

set -e
yum -y install curl unzip nc autoconf automake zip rpm-build git-all


git clone https://github.com/rerun/roundup.git

cd roundup
./configure
make
make install

