#!/bin/bash

# Continuous Integration at https://travis-ci.org/rerun/rerun
cat /etc/apt/sources.list
autoreconf --install
./configure
make check
