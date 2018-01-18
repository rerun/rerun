# Create by stagr.lee@gmail.com 27SEP11
# copyright rerun.sh, 2017

## Process this file with automake to produce Makefile.in

#ACLOCAL_AMFLAGS = -I m4 --install

# setup is only used by distribution developers, not package developers.
# Still, as a matter of allowing patching, its not a bad idea to distribute
# the developer setup script in the tarball.
EXTRA_DIST = \
  setup.sh \
  etc/bash_completion.sh \
  etc/devpkg.spec

# README.md is expected in Github projects, good stuff in it, so we'll
# distribute it and install it with the package in the doc directory.
docdir = ${datadir}/doc/${PACKAGE}
dist_doc_DATA = README.md INSTALL COPYING AUTHORS README NEWS ChangeLog

ChangeLog:
	git log --name-status > $@ || echo "no changelog" > $@

# the main script
dist_bin_SCRIPTS = rerun

# man pages here
dist_man_MANS = man/man1/rerun.1

# by convention, automake hates putting data and script files in /usr/lib
# using something like nobase_dist_pkglib_SCRIPTS.  To get around this
# we will create our own directory name, tried libdir and that didn't 
# work for debian packages.
moddir = ${prefix}/lib/${PACKAGE}
nobase_dist_mod_DATA = \
	modules/stubbs/README.md \
	modules/stubbs/commands/add-command/metadata \
	modules/stubbs/commands/add-command/README.md \
	modules/stubbs/commands/add-module/metadata \
	modules/stubbs/commands/add-module/README.md \
	modules/stubbs/commands/add-option/metadata \
	modules/stubbs/commands/add-option/README.md \
	modules/stubbs/commands/archive/metadata \
	modules/stubbs/commands/archive/README.md \
	modules/stubbs/commands/docs/metadata \
	modules/stubbs/commands/docs/README.md \
	modules/stubbs/commands/edit/metadata \
	modules/stubbs/commands/edit/README.md \
	modules/stubbs/commands/migrate/metadata \
	modules/stubbs/commands/migrate/README.md \
	modules/stubbs/commands/rm-command/metadata \
	modules/stubbs/commands/rm-command/README.md \
	modules/stubbs/commands/rm-option/metadata \
	modules/stubbs/commands/rm-option/README.md \
	modules/stubbs/commands/test/metadata \
	modules/stubbs/commands/test/README.md \
	modules/stubbs/lib/docs.css \
	modules/stubbs/lib/stub/bash/metadata \
	modules/stubbs/lib/stub/bash/templates/functions.sh \
	modules/stubbs/lib/stub/bash/templates/script \
	modules/stubbs/lib/stub/README.md \
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
	modules/stubbs/options/generate-help/metadata \
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
	modules/stubbs/templates/rerun-module.spec \
	modules/stubbs/templates/test.functions.sh \
	modules/stubbs/templates/test.roundup

# The module scripts
nobase_dist_mod_SCRIPTS = \
	modules/stubbs/bin/roundup \
	modules/stubbs/bin/shocco.sh \
	modules/stubbs/bin/Markdown.pl \
	modules/stubbs/commands/add-command/options.sh \
	modules/stubbs/commands/add-command/script \
	modules/stubbs/commands/add-module/options.sh \
	modules/stubbs/commands/add-module/script \
	modules/stubbs/commands/add-option/options.sh \
	modules/stubbs/commands/add-option/script \
	modules/stubbs/commands/archive/options.sh \
	modules/stubbs/commands/archive/script \
	modules/stubbs/commands/docs/options.sh \
	modules/stubbs/commands/docs/script \
	modules/stubbs/commands/edit/script \
	modules/stubbs/commands/migrate/options.sh \
	modules/stubbs/commands/migrate/script \
	modules/stubbs/commands/rm-command/script \
	modules/stubbs/commands/rm-option/script \
	modules/stubbs/commands/test/script \
	modules/stubbs/lib/docs-functions \
	modules/stubbs/lib/functions.sh \
	modules/stubbs/lib/stub/bash/generate-options \
	modules/stubbs/lib/test.sh \
	modules/stubbs/tests/add-command-1-test.sh \
	modules/stubbs/tests/add-module-1-test.sh \
	modules/stubbs/tests/add-option-1-test.sh \
	modules/stubbs/tests/archive-1-test.sh \
	modules/stubbs/tests/docs-1-test.sh \
	modules/stubbs/tests/functional-bash-1-test.sh \
	modules/stubbs/tests/functional-bash-2-test.sh \
	modules/stubbs/tests/migrate-1-test.sh \
	modules/stubbs/tests/rm-command-1-test.sh \
	modules/stubbs/tests/rm-option-1-test.sh \
	modules/stubbs/tests/stubbs-functions-1-test.sh \
	modules/stubbs/tests/functions.sh

# put the tests in /usr/libexec/rerun using built in macro
nobase_dist_pkglibexec_SCRIPTS = \
  tests/rerun-0-test.sh \
  tests/rerun-1-test.sh \
  tests/rerun-2-test.sh \
  tests/rerun-4-test.sh

testdir = ${libexecdir}/${PACKAGE}
nobase_dist_test_DATA = \
  tests/functions.sh

dist_pkglibexec_SCRIPTS = \
  etc/travis-ci-modules.sh

# bash completion script into $(sysconfdir)/bash_completion.d/
# most unix implementations do not set the executable permission
# so well ship it as a data file.  Its a bit wonky to have
# $(prefix)/bin/rerun and /etc/bash_completion.d/rerun
# being the same target name so I'll use a install hook

install-data-local:
	mkdir -p $(DESTDIR)$(sysconfdir)/bash_completion.d
	cp -p $(srcdir)/etc/bash_completion.sh \
		$(DESTDIR)$(sysconfdir)/bash_completion.d/$(PACKAGE)

uninstall-local:
	rm -f $(DESTDIR)$(sysconfdir)/bash_completion.d/$(PACKAGE)

#
# Doc targets
#
man:
	sed "s/1\.4\.x/$(VERSION)/g" README.md | pandoc -s -w man -o man/man1/rerun.1

#
# Testing targets
#
test: check
check: test-rerun test-stubbs

# TODO: Until issue 147 https://github.com/rerun/rerun/issues/147 is
# dealt with, we need to open up the write priv for the modules directory
test-rerun:
	echo "Testing rerun from $(srcdir) ..."
	export RERUN="$(srcdir)/rerun"; \
	export RERUN_MODULES="$(srcdir)/modules"; \
	export LC_ALL="C"; \
	if [ ! -w $${RERUN_MODULES} ]; then \
		CLEANUPDIRS="true"; \
		chmod u+w $${RERUN_MODULES}; \
	fi; \
	set -e; \
	for i in $(srcdir)/tests/*-test.sh; \
	do \
	  $${RERUN_MODULES}/stubbs/bin/roundup $${i}; \
	done; \
	if [[ "$${CLEANUPDIRS}" = "true" ]]; then chmod u-w $${RERUN_MODULES}; fi
test-stubbs:
	echo "Testing stubbs module..."; \
	if [[ "$${PWD}x" = "x" ]]; then export PWD="$(shell pwd)"; fi; \
	if [[ "$(srcdir)" = "/*" ]]; then MYDIR="$(srcdir)"; else MYDIR="$${PWD}/$(srcdir)"; fi; \
	export RERUN="$${MYDIR}/rerun"; \
	export RERUN_MODULES="$${MYDIR}/modules"; \
	export LC_ALL="C"; \
	echo "    modules at $${RERUN_MODULES}"; \
	if [ ! -w $${RERUN_MODULES} ]; then \
		CLEANUPDIRS="true"; \
		chmod u+w $${RERUN_MODULES} $${RERUN_MODULES}/stubbs/tests; \
	fi; \
	set -e; \
	$${RERUN} stubbs:test --module stubbs; \
	if [[ "$${CLEANUPDIRS}" = "true" ]]; then \
		chmod u-w $${RERUN_MODULES} $${RERUN_MODULES}/stubbs/tests; \
	fi

rerun-$(VERSION).bin:
	echo "Packaging rerun as a bin..."; \
	if [[ "$${PWD}x" = "x" ]]; then export PWD="$(shell pwd)"; fi; \
	if [[ "$(srcdir)" = "/*" ]]; then MYDIR="$(srcdir)"; else MYDIR="$${PWD}/$(srcdir)"; fi; \
	export RERUN="$${MYDIR}/rerun"; \
	export RERUN_MODULES="$${MYDIR}/modules"; \
	export LC_ALL="C"; \
	echo "    modules at $${RERUN_MODULES}"; \
	set -e; \
	$${RERUN} stubbs:archive --modules stubbs --version $(VERSION) --file rerun-$(VERSION).bin; \
	./rerun-$(VERSION).bin;

#unset RERUN_COLOR
#
# RPM packaging target (defaulting the release if none specified externally):
#
RELEASE ?= 1

rerun-$(VERSION)-1.linux.noarch.rpm:
	@echo "Packaging rerun as an RPM ..."
	mkdir -p $(builddir)/rpm/SOURCES $(builddir)/rpm/BUILD $(builddir)/rpm/RPMS \
		$(builddir)/rpm/SRPMS $(builddir)/rpm/SPECS $(builddir)/rpm/tmp
	cp -f $(srcdir)/rerun-$(VERSION).tar.gz $(builddir)/rpm/SOURCES/
	rpmbuild -ba --target noarch \
                --define "dist .linux" \
		--define "major `echo $(VERSION) | cut -d. -f1`" \
		--define "minor `echo $(VERSION) | cut -d. -f2`" \
		--define "revision `echo $(VERSION) | cut -d. -f3`" \
		--define "_topdir ${PWD}/rpm" \
		--define "_tmppath ${PWD}/rpm/tmp" \
		--define "version $(VERSION)" \
		--define "release ${RELEASE}" \
		$(srcdir)/etc/devpkg.spec
	find $(builddir)/rpm/{RPMS,SRPMS}/ -name "*.rpm" -exec mv {} ./ \;

rerun_$(VERSION)-1_all.deb:
	@echo "Packaging rerun as an Debian ..."
	mkdir -p $(builddir)/deb
	cp -f $(srcdir)/rerun-$(VERSION).tar.gz $(builddir)/deb/rerun_$(VERSION).orig.tar.gz
	cd $(builddir)/deb; \
	tar xzf rerun_$(VERSION).orig.tar.gz; \
	cd rerun-$(VERSION); \
	DEBFULLNAME="rerun-discuss@googlegroups.com"; \
	dh_make --yes --indep --copyright apache --email rerun-discuss@googlegroups.com
	sed -i  -e 's/ unknown$$/ shells/g' \
		-e 's/ root / stagrlee /g' \
		-e 's@^Homepage:.*$$@Homepage: http://rerun.github.io/rerun@g' \
		-e 's/^Description:.*$$/Description: Command runner to make remembering procedures easier/g' \
		-e '/^Depends:.*$$/d' \
		-e '$$d' \
		$(builddir)/deb/rerun-$(VERSION)/debian/control
	echo -e \
	" Rerun is a simple command runner that turns loose shell scripts\n" \
	" into modular automation. Rerun will help you organize your implementation\n" \
	" into well defined command interfaces. Collections of management modules\n" \
	" can be archived and delivered as a single executable to facilitate team\n" \
	" hand offs. Using the stubbs module, rerun will even facilitate\n" \
	" developing modules using a test-driven development practice.\c" \
	>> $(builddir)/deb/rerun-$(VERSION)/debian/control
	sed -i 	-e 's@^Source:.*$$@Source: https://github.com/rerun/rerun@' \
		-e 's/^Copyright:.*$$/Copyright: 2011-2014, Alex Honor AlexHonor@yahoo.com/' \
		-e '/likewise for another/d' \
		-e '/^# /d' \
		$(builddir)/deb/rerun-$(VERSION)/debian/copyright
	rm -f $(builddir)/deb/rerun-$(VERSION)/debian/*\.ex
	rm -f $(builddir)/deb/rerun-$(VERSION)/debian/*\.EX
	cd $(builddir)/deb/rerun-$(VERSION); debuild -us -uc
	mv $(builddir)/deb/rerun_* ./

bin: rerun-$(VERSION).bin

deb: rerun_$(VERSION)-1_all.deb

rpm: rerun-$(VERSION)-1.linux.noarch.rpm

rerun-bintray.sh:
	wget --output-document rerun-bintray.sh https://dl.bintray.com/rerun/rerun-modules/bintray/1.0.3/rerun.sh
	chmod 755 rerun-bintray.sh

release: rerun-$(VERSION)-1.linux.noarch.rpm rerun_$(VERSION)-1_all.deb rerun-$(VERSION).bin rerun-bintray.sh
	@echo "Releasing Rerun"
	./rerun-bintray.sh bintray: package-upload-deb --apikey $${BINTRAY_APIKEY} --file rerun_$(VERSION)-1_all.deb --version $(VERSION)-1 --user $${BINTRAY_USER} --deb_architecture all --org rerun --repo rerun-deb --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun_$(VERSION)-1.debian.tar.gz --version $(VERSION)-1 --user $${BINTRAY_USER} --org rerun --repo rerun-deb --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun_$(VERSION)-1.dsc --version $(VERSION)-1 --user $${BINTRAY_USER} --org rerun --repo rerun-deb --package rerun dist
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun_$(VERSION)-1_amd64.build --version $(VERSION)-1 --user $${BINTRAY_USER} --org rerun --repo rerun-deb --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun_$(VERSION)-1_amd64.changes --version $(VERSION)-1 --user $${BINTRAY_USER} --org rerun --repo rerun-deb --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun_$(VERSION).orig.tar.gz --version $(VERSION)-1 --user $${BINTRAY_USER} --org rerun --repo rerun-deb --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun-$(VERSION).bin --version $(VERSION) --user $${BINTRAY_USER} --org rerun --repo rerun-bin --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun-$(VERSION).tar.bz2 --version $(VERSION) --user $${BINTRAY_USER} --org rerun --repo rerun-bin --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun-$(VERSION).tar.gz --version $(VERSION) --user $${BINTRAY_USER} --org rerun --repo rerun-bin --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun-$(VERSION).zip --version $(VERSION) --user $${BINTRAY_USER} --org rerun --repo rerun-bin --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun-$(VERSION)-1.linux.noarch.rpm --version $(VERSION) --user $${BINTRAY_USER} --org rerun --repo rerun-rpm --package rerun
	./rerun-bintray.sh bintray: package-upload --apikey $${BINTRAY_APIKEY} --file rerun-$(VERSION)-1.linux.src.rpm --version $(VERSION) --user $${BINTRAY_USER} --org rerun --repo rerun-rpm --package rerun


release-bin: bin
	@echo "Releasing Rerun"
	echo -n "Enter bintray username and press [ENTER]: "; \
	read BINTRAY_USER; \
	echo -n "Enter bintray apikey and press [ENTER]: "; \
	read BINTRAY_APIKEY; \
	./rerun bintray:package-upload --user $${BINTRAY_USER} --apikey $${BINTRAY_APIKEY} \
		--org rerun --repo rerun-bin --package rerun --version $(VERSION) --file rerun-$(VERSION).bin

.PHONY: bin rpm deb test-rerun test-stubbs
