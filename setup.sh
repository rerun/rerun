#!/usr/bin/env bash

export LC_ALL=C
RERUN_VERSION=$(grep ^RERUN_VERSION rerun  | cut -d= -f2)

# RUN ME after pulling the code from git!
if [ "clean" == "$1" ]; then
  if [[ -e Makefile ]]
  then
    make distclean
  fi

  if [[ -d rerun-${RERUN_VERSION} ]]
  then
    find rerun-${RERUN_VERSION} -type d -exec chmod 755 {} \;
    rm -rf tmp rerun-* autom4te.cache config
  fi

  rm -f INSTALL ChangeLog Makefile.in aclocal.m4 configure rerun-${RERUN_VERSION}* rerun-stubbs-*.rpm
  rm -rf rpm autom4te.cache config tmp
else
  autoreconf --install
  ./configure
  mkdir -p tmp
  make DESTDIR=./tmp install
  make distcheck
fi
