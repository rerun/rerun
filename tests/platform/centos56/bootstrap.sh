#!/usr/bin/env bash

yum -y install curl unzip nc autoconf automake zip rpm-build

# Add the Webtatic repository to get git software.
rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm

# Install the latest version of git
yum -y install --enablerepo=webtatic git-all

git clone https://github.com/rerun/rerun.git
cd rerun
./setup.sh
