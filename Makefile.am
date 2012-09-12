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
dist_doc_DATA = README.md INSTALL COPYING AUTHORS README NEWS ChangeLog

# the main script
dist_bin_SCRIPTS = rerun

# man pages here
dist_man_MANS = modules/stubbs/stubbs.1

# The module
nobase_dist_pkgdata_DATA = \
	modules/stubbs/commands/add-command/default.sh \
	modules/stubbs/commands/add-command/metadata \
	modules/stubbs/commands/add-command/module.option \
	modules/stubbs/commands/add-command/command.option \
	modules/stubbs/commands/add-command/options.sh \
	modules/stubbs/commands/add-command/overwrite.option \
	modules/stubbs/commands/add-command/template.option \
	modules/stubbs/commands/add-module/default.sh \
	modules/stubbs/commands/add-module/description.option \
	modules/stubbs/commands/add-module/metadata \
	modules/stubbs/commands/add-module/module.option \
	modules/stubbs/commands/add-option/arg.option \
	modules/stubbs/commands/add-option/command.option \
	modules/stubbs/commands/add-option/default.sh \
	modules/stubbs/commands/add-option/desc.option \
	modules/stubbs/commands/add-option/metadata \
	modules/stubbs/commands/add-option/module.option \
	modules/stubbs/commands/add-option/option.option \
	modules/stubbs/commands/add-option/required.option \
	modules/stubbs/commands/archive/default.sh \
	modules/stubbs/commands/archive/file.option \
	modules/stubbs/commands/archive/metadata \
	modules/stubbs/commands/archive/modules.option \
	modules/stubbs/commands/archive/options.sh \
	modules/stubbs/commands/docs/default.sh \
	modules/stubbs/commands/docs/metadata \
	modules/stubbs/commands/docs/module.option \
	modules/stubbs/commands/docs/options.sh \
	modules/stubbs/commands/test/default.sh \
	modules/stubbs/commands/test/logs.option \
	modules/stubbs/commands/test/metadata \
	modules/stubbs/commands/test/module.option \
	modules/stubbs/lib/functions.sh \
	modules/stubbs/metadata \
	modules/stubbs/README.md \
	modules/stubbs/stubbs.1 \
	modules/stubbs/templates/default.sh \
	modules/stubbs/templates/extract \
	modules/stubbs/templates/functions.sh \
	modules/stubbs/templates/launcher \
	modules/stubbs/templates/test.sh

# bash completion script into $(sysconfdir)/bash_completion.d/
# most unix implementations do not set the executable permission
# so well ship it as a data file.  Its a bit wonky to have
# $(prefix)/bin/rerun and $(prefix)/etc/bash_completion.d/rerun
# being the same target name so I'll use a install hook

install-data-hook:
	mkdir -p $(DESTDIR)$(sysconfdir)/bash_completion.d
	cp -p $(srcdir)/bash_completion.sh \
		$(DESTDIR)$(sysconfdir)/bash_completion.d/$(PACKAGE)

