#!/usr/bin/env bash

set -e
export LC_ALL=C
RERUN_VERSION=$(grep ^RERUN_VERSION rerun  | cut -d= -f2)

# RUN ME after pulling the code from git!
if [[ "clean" == "$1" ]]; then
  if [[ -e Makefile ]]
  then
    make distclean
  fi

  if [[ -d "rerun-${RERUN_VERSION}" ]]
  then
    find "rerun-${RERUN_VERSION}" -type d -exec chmod 755 {} \;
  fi

  rm -f INSTALL ChangeLog Makefile.in aclocal.m4 configure rerun-stubbs* rerun-bintray.sh
  rm -rf tmp rerun[-_]${RERUN_VERSION}* autom4te.cache config
  rm -rf rpm autom4te.cache config tmp deb
elif [[ "regress" == "$1" ]]; then
  ./setup.sh clean
  ./setup.sh
  make bin rpm deb
  make release
else
  autoreconf --install
  ./configure
  mkdir -p tmp
  make DESTDIR=./tmp install
  make distcheck
fi
