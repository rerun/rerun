#!/bin/sh

set -e

unset RERUN_COLOR
export RERUN=`pwd`/rerun
export RERUN_MODULES=`pwd`/modules

autoreconf --install 
./configure 
make test
