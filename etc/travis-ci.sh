#!/bin/bash

# Continuous Integration at https://travis-ci.org/rerun/rerun

# set version patch number to build number from travis
sed -i -r 's,^RERUN_VERSION=([0-9]+\.[0-9]+)\.0$,RERUN_VERSION=\1.'"${TRAVIS_BUILD_NUMBER}"',g' rerun
grep '^RERUN_VERSION=' rerun

autoreconf --install
./configure
make check

# make the distributions
make bin deb rpm

if [[ "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
  # Time to push to bintray
  echo releaseit
else
  echo "Travis-CI sayz LGTM"
fi
