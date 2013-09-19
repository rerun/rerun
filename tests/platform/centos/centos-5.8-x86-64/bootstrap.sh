#!/usr/bin/env bash

set -e
yum -y install curl unzip nc autoconf automake zip rpm-build buildsys-macros

# Add the Webtatic repository to get git software.
rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm
yum -y install --enablerepo=webtatic git-all

# Get roundup
cd /tmp
git clone https://github.com/rerun/roundup.git
cd roundup
./configure --prefix=/usr
make
make install

which roundup
