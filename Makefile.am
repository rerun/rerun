# Create by thompson@dtosolutions.com 27SEP11
# copyright DTOSOLUTIONS, 2011

## Process this file with automake to produce Makefile.in
 
#ACLOCAL_AMFLAGS = -I m4 --install

# setup is only used by distribution developers, not package developers.
# Still, as a matter of allowing patching, its not a bad idea to distribute 
# the developer setup script in the tarball.
EXTRA_DIST = setup.sh bash_completion.sh

# README.md is expected in Github projects, good stuff in it, so we'll 
# distribute it and install it with the package in the doc directory.
docdir = ${datadir}/doc/${PACKAGE} 
dist_doc_DATA = README.md INSTALL COPYING AUTHORS README NEWS ChangeLog

# the main script
dist_bin_SCRIPTS = rerun

# man pages here
dist_man_MANS = modules/stubbs/stubbs.1

# The module
nobase_dist_pkgdata_DATA = \
	modules/stubbs/README.md \
	modules/stubbs/bin/roundup \
	modules/stubbs/commands/add-command/metadata \
	modules/stubbs/commands/add-command/options.sh \
	modules/stubbs/commands/add-command/script \
	modules/stubbs/commands/add-module/metadata \
	modules/stubbs/commands/add-module/script \
	modules/stubbs/commands/add-option/metadata \
	modules/stubbs/commands/add-option/script \
	modules/stubbs/commands/archive/metadata \
	modules/stubbs/commands/archive/options.sh \
	modules/stubbs/commands/archive/script \
	modules/stubbs/commands/docs/metadata \
	modules/stubbs/commands/docs/options.sh \
	modules/stubbs/commands/docs/script \
	modules/stubbs/commands/edit/metadata \
	modules/stubbs/commands/edit/script \
	modules/stubbs/commands/migrate/metadata \
	modules/stubbs/commands/migrate/options.sh \
	modules/stubbs/commands/migrate/script \
	modules/stubbs/commands/rm-option/metadata \
	modules/stubbs/commands/rm-option/script \
	modules/stubbs/commands/test/metadata \
	modules/stubbs/commands/test/script \
	modules/stubbs/lib/functions.sh \
	modules/stubbs/lib/interpreters/README.md \
	modules/stubbs/lib/interpreters/bash/generate-options \
	modules/stubbs/lib/interpreters/bash/metadata \
	modules/stubbs/lib/interpreters/bash/templates/functions.sh \
	modules/stubbs/lib/interpreters/bash/templates/script \
	modules/stubbs/lib/interpreters/groovy/generate-options \
	modules/stubbs/lib/interpreters/groovy/metadata \
	modules/stubbs/lib/interpreters/groovy/templates/functions \
	modules/stubbs/lib/interpreters/groovy/templates/script \
	modules/stubbs/lib/interpreters/python/generate-options \
	modules/stubbs/lib/interpreters/python/metadata \
	modules/stubbs/lib/interpreters/python/templates/functions.py \
	modules/stubbs/lib/interpreters/python/templates/script \
	modules/stubbs/lib/test.sh \
	modules/stubbs/metadata \
	modules/stubbs/options/arg/metadata \
	modules/stubbs/options/command/metadata \
	modules/stubbs/options/default/metadata \
	modules/stubbs/options/description/metadata \
	modules/stubbs/options/export/metadata \
	modules/stubbs/options/file/metadata \
	modules/stubbs/options/format/metadata \
	modules/stubbs/options/interpreter/metadata \
	modules/stubbs/options/logs/metadata \
	modules/stubbs/options/long/metadata \
	modules/stubbs/options/module/metadata \
	modules/stubbs/options/modules/metadata \
	modules/stubbs/options/option/metadata \
	modules/stubbs/options/overwrite/metadata \
	modules/stubbs/options/plan/metadata \
	modules/stubbs/options/range/metadata \
	modules/stubbs/options/release/metadata \
	modules/stubbs/options/required/metadata \
	modules/stubbs/options/short/metadata \
	modules/stubbs/options/template/metadata \
	modules/stubbs/options/version/metadata \
	modules/stubbs/stubbs.1 \
	modules/stubbs/templates/extract \
	modules/stubbs/templates/launcher \
	modules/stubbs/templates/rerun-module.spec \
	modules/stubbs/templates/test.functions.sh \
	modules/stubbs/templates/test.roundup \
	modules/stubbs/templates/test.functions.sh \
	modules/stubbs/tests/add-command-1-test.sh \
	modules/stubbs/tests/add-module-1-test.sh \
	modules/stubbs/tests/add-option-1-test.sh \
	modules/stubbs/tests/archive-1-test.sh \
	modules/stubbs/tests/docs-1-test.sh \
	modules/stubbs/tests/functional-bash-test.sh \
	modules/stubbs/tests/migrate-1-test.sh \
	modules/stubbs/tests/rm-option-1-test.sh

# bash completion script into $(sysconfdir)/bash_completion.d/
# most unix implementations do not set the executable permission
# so well ship it as a data file.  Its a bit wonky to have
# $(prefix)/bin/rerun and $(prefix)/etc/bash_completion.d/rerun
# being the same target name so I'll use a install hook

install-data-hook:
	mkdir -p $(DESTDIR)$(sysconfdir)/bash_completion.d
	cp -p $(srcdir)/bash_completion.sh \
		$(DESTDIR)$(sysconfdir)/bash_completion.d/$(PACKAGE)

#
# Testing targets
#

test: test-rerun test-stubbs
test-rerun:
	@echo "Testing rerun ..."
	cd ./tests && ../modules/stubbs/bin/roundup
test-stubbs:
	@echo "Testing stubbs module..."
	./rerun stubbs:test --module stubbs

#
# RPM packaging target (defaulting the release if none specified externally):
#
RELEASE ?= 1

rpmbuild:
	@echo "Packaging rerun as an RPM ..."
	mkdir -p SOURCES BUILD BUILDROOT RPMS
	cp -f rerun-${VERSION}.zip SOURCES/rerun-${VERSION}.zip
	rpmbuild --target noarch --buildroot ${PWD}/BUILDROOT/rerun-${VERSION}-${RELEASE}.noarch --define "_topdir ${PWD}" --define "version ${VERSION}" --define "release ${RELEASE}" -bb --clean SPECS/rerun.spec
