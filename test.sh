#!/bin/sh

set -e

autoreconf --install 
./configure 
make test
