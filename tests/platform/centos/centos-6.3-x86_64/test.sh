#!/usr/bin/env bash

for tests in $@
do
	cd "$tests"
	roundup
done