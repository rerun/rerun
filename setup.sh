#!/usr/bin/env bash

# RUN ME after pulling the code from git!
if [ "clean" == "$1" ]; then
  make distclean
  chmod -R u+w rerun-*
  rm -rf tmp rerun-* autom4te.cache config
  rm INSTALL Makefile.in aclocal.m4 configure
else
  autoreconf --install
  ./configure --prefix=/opt/junk
  mkdir tmp
  make DESTDIR=./tmp install
  make distcheck
fi
