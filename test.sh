#!/bin/sh

set -e

unset RERUN_COLOR
RERUN=`pwd`/rerun
RERUN_MODULES=`pwd`/modules

autoreconf --install 
./configure 
make test
