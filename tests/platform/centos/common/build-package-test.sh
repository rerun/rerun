#!/usr/bin/env roundup

describe "Test the RPM build and install process"

BUILD_DIR=$(mktemp -d "/tmp/rerun-build.XXXX")

before() {
	mkdir -p $BUILD_DIR
}

after() {
	:;	#rm -rf $BUILD_DIR
}

it_builds_package_from_source() {
	cd $BUILD_DIR

	git clone https://github.com/rerun/rerun.git
	cd rerun
	./setup.sh
	version=($(awk -F= '/^PACKAGE_VERSION/ {print $2}' $BUILD_DIR/rerun/Makefile))

	make rpm

	shopt -s nullglob
	rpm=( rerun-${version}-*.noarch.rpm )
	ls $rpm
	(( ${#rpm[*]} != 1)) && { echo "rpm not found"; return 1 ; }
	test -f "$rpm"

	rpm -i "$rpm"
	rpm -q rerun --info
}

it_lives_in_default_path() {
	type rerun
}

it_installs_in_standard_locations() {	
    test -x /usr/bin/rerun
    test -d /usr/lib/rerun
    test -d /usr/lib/rerun/modules
    test -d /usr/lib/rerun/modules/stubbs
    test -f /etc/bash_completion.d/rerun
    test -f /usr/share/man/man1/rerun.1
}

it_performs_rerun_module_listings() {
	rerun | grep stubbs
}

it_performs_rerun_command_listings() {
	rerun stubbs
}

it_performs_rerun_stubbs_tests() {
	rerun stubbs:test --module stubbs
}
