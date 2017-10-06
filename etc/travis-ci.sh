#!/bin/bash

# Continuous Integration at https://travis-ci.org/rerun/rerun

# set version patch number to build number from travis
sed -i -r 's,^RERUN_VERSION=([0-9]+\.[0-9]+)\.0$,RERUN_VERSION=\1.'"${TRAVIS_BUILD_NUMBER}"',g' rerun
grep '^RERUN_VERSION=' rerun

autoreconf --install
./configure
make check
