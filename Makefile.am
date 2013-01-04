# Create by thompson@dtosolutions.com 27SEP11
# copyright DTOSOLUTIONS, 2011

## Process this file with automake to produce Makefile.in
 
#ACLOCAL_AMFLAGS = -I m4 --install

# setup is only used by distribution developers, not package developers.
# Still, as a matter of allowing patching, its not a bad idea to distribute 
# the developer setup script in the tarball.
EXTRA_DIST = \
  bash_completion.sh \
  ChangeLog \
  devpkg.spec \
  setup.sh \
  test.sh \
  tests/functions.sh \
  tests/rerun-0-test.sh \
  tests/rerun-1-test.sh \
  tests/rerun-2-test.sh \
  tests/rerun-4-test.sh

# README.md is expected in Github projects, good stuff in it, so we'll 
# distribute it and install it with the package in the doc directory.
docdir = ${datadir}/doc/${PACKAGE}
dist_doc_DATA = README.md INSTALL COPYING AUTHORS README NEWS ChangeLog

ChangeLog:
	git log --name-status > $@ || echo "no changelog" > $@

# the main script
dist_bin_SCRIPTS = rerun

# man pages here
dist_man_MANS = 

# The module
nobase_dist_pkgdata_DATA = \
	modules/stubbs/README.md \
	modules/stubbs/bin/roundup \
	modules/stubbs/bin/shocco \
	modules/stubbs/bin/Markdown.pl \
	modules/stubbs/commands/add-command/metadata \
	modules/stubbs/commands/add-command/options.sh \
	modules/stubbs/commands/add-command/README.md \
	modules/stubbs/commands/add-command/script \
	modules/stubbs/commands/add-module/metadata \
	modules/stubbs/commands/add-module/script \
	modules/stubbs/commands/add-module/README.md \
	modules/stubbs/commands/add-option/metadata \
	modules/stubbs/commands/add-option/script \
	modules/stubbs/commands/add-option/README.md \
	modules/stubbs/commands/archive/metadata \
	modules/stubbs/commands/archive/options.sh \
	modules/stubbs/commands/archive/script \
	modules/stubbs/commands/archive/README.md \
	modules/stubbs/commands/docs/metadata \
	modules/stubbs/commands/docs/options.sh \
	modules/stubbs/commands/docs/script \
	modules/stubbs/commands/docs/README.md \
	modules/stubbs/commands/edit/metadata \
	modules/stubbs/commands/edit/script \
	modules/stubbs/commands/edit/README.md \
	modules/stubbs/commands/migrate/metadata \
	modules/stubbs/commands/migrate/options.sh \
	modules/stubbs/commands/migrate/script \
	modules/stubbs/commands/migrate/README.md \
	modules/stubbs/commands/rm-option/metadata \
	modules/stubbs/commands/rm-option/script \
	modules/stubbs/commands/rm-option/README.md \
	modules/stubbs/commands/test/metadata \
	modules/stubbs/commands/test/script \
	modules/stubbs/commands/test/README.md \
	modules/stubbs/lib/docs.css \
	modules/stubbs/lib/docs.sh \
	modules/stubbs/lib/functions.sh \
	modules/stubbs/lib/stub/bash/generate-options \
	modules/stubbs/lib/stub/bash/metadata \
	modules/stubbs/lib/stub/bash/templates/functions.sh \
	modules/stubbs/lib/stub/bash/templates/script \
	modules/stubbs/lib/stub/README.md \
	modules/stubbs/lib/test.sh \
	modules/stubbs/metadata \
	modules/stubbs/options/answers/metadata \
	modules/stubbs/options/answers/README.md \
	modules/stubbs/options/arg/metadata \
	modules/stubbs/options/arg/README.md \
	modules/stubbs/options/command/metadata \
	modules/stubbs/options/command/README.md \
	modules/stubbs/options/default/metadata \
	modules/stubbs/options/default/README.md \
	modules/stubbs/options/description/metadata \
	modules/stubbs/options/description/README.md \
	modules/stubbs/options/dir/metadata \
	modules/stubbs/options/dir/README.md \
	modules/stubbs/options/export/metadata \
	modules/stubbs/options/export/README.md \
	modules/stubbs/options/file/metadata \
	modules/stubbs/options/file/README.md \
	modules/stubbs/options/format/metadata \
	modules/stubbs/options/format/README.md \
	modules/stubbs/options/long/metadata \
	modules/stubbs/options/long/README.md \
	modules/stubbs/options/module/metadata \
	modules/stubbs/options/module/README.md \
	modules/stubbs/options/modules/metadata \
	modules/stubbs/options/modules/README.md \
	modules/stubbs/options/option/metadata \
	modules/stubbs/options/option/README.md \
	modules/stubbs/options/overwrite/metadata \
	modules/stubbs/options/overwrite/README.md \
	modules/stubbs/options/plan/metadata \
	modules/stubbs/options/plan/README.md \
	modules/stubbs/options/range/metadata \
	modules/stubbs/options/range/README.md \
	modules/stubbs/options/release/metadata \
	modules/stubbs/options/release/README.md \
	modules/stubbs/options/required/metadata \
	modules/stubbs/options/required/README.md \
	modules/stubbs/options/short/metadata \
	modules/stubbs/options/short/README.md \
	modules/stubbs/options/template/metadata \
	modules/stubbs/options/template/README.md \
	modules/stubbs/options/version/metadata \
	modules/stubbs/options/version/README.md \
	modules/stubbs/stubbs.1 \
	modules/stubbs/templates/extract \
	modules/stubbs/templates/launcher \
	modules/stubbs/templates/rerun-module.spec.txt \
	modules/stubbs/templates/test.functions.sh \
	modules/stubbs/templates/test.roundup \
	modules/stubbs/tests/add-command-1-test.sh \
	modules/stubbs/tests/add-module-1-test.sh \
	modules/stubbs/tests/add-option-1-test.sh \
	modules/stubbs/tests/archive-1-test.sh \
	modules/stubbs/tests/docs-1-test.sh \
	modules/stubbs/tests/functional-bash-1-test.sh \
	modules/stubbs/tests/migrate-1-test.sh \
	modules/stubbs/tests/rm-option-1-test.sh \
	modules/stubbs/tests/stubbs-functions-1-test.sh

# bash completion script into $(sysconfdir)/bash_completion.d/
# most unix implementations do not set the executable permission
# so well ship it as a data file.  Its a bit wonky to have
# $(prefix)/bin/rerun and /etc/bash_completion.d/rerun
# being the same target name so I'll use a install hook

install-data-local:
	mkdir -p $(DESTDIR)$(sysconfdir)/bash_completion.d
	cp -p $(srcdir)/bash_completion.sh \
		$(DESTDIR)$(sysconfdir)/bash_completion.d/$(PACKAGE)

uninstall-local:
	rm -f $(DESTDIR)$(sysconfdir)/bash_completion.d/$(PACKAGE)


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

rpm:
	@echo "Packaging rerun as an RPM ..."
	mkdir -p rpm/SOURCES rpm/BUILD rpm/BUILDROOT rpm/RPMS
	cp -f rerun-${VERSION}.tar.gz rpm/SOURCES/rerun-${VERSION}.tar.gz
	rpmbuild -tb --target noarch --define "_topdir ${PWD}/rpm" --define "version ${VERSION}" --define "release ${RELEASE}" rpm/SOURCES/rerun-${VERSION}.tar.gz
	find rpm/RPMS/ -name "*.rpm" -exec mv {} ./ \;
