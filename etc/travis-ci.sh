#!/bin/bash
set -e

# Continuous Integration at https://travis-ci.org/rerun/rerun

# set version patch number to build number from travis
sed -i -r 's,^RERUN_VERSION=([0-9]+\.[0-9]+)\.0$,RERUN_VERSION=\1.'"${TRAVIS_BUILD_NUMBER}"',g' rerun
grep '^RERUN_VERSION=' rerun

autoreconf --install
./configure
mkdir -p tmp
make DESTDIR=./tmp install
make distcheck

# make the distributions
make bin deb rpm

if [[ "${TRAVIS_BRANCH}" == "master" && "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
  # Time to push to bintray
  make release
else
  echo "Travis-CI sayz LGTM"
fi
