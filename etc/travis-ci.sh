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
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  echo "Tagging version in git"
  eval export $(grep ^RERUN_VERSION= rerun)
  git tag -a "v${RERUN_VERSION}" -m "skip ci - Travis CI release v${RERUN_VERSION}"
  echo "Pushing tag v${RERUN_VERSION}"
  git push --quiet "https://${GH_TOKEN}@github.com/rerun/rerun" --tags > /dev/null 2>&1
  # Time to push to bintray
  make release
else
  echo "***************************"
  echo "***                     ***"
  echo "*** Travis-CI sayz LGTM ***"
  echo "***                     ***"
  echo "***************************"
fi
