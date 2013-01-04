#
# This is a package used by the development team to assist 
# users who use OS's are RPM based but don't have rerun 
# provided by their OS team
#
Summary: Dance your way through standard operating procedure
Name: rerun
Version: %{version}
Release: %{release}
Source0: rerun-%{version}.tar.gz
URL: http://rerun.github.com/rerun

License: ASL 2.0
Group: Applications/System
Requires: bash
Provides: rerun

# Disables debug packages and stripping of binaries:
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post %{nil}

%description
A simple command runner because it's easy to forget standard operating procedure.

%prep

%setup

%build
./configure
make

%install
echo "Installing to: \"${_buildroot}\""
make install DESTDIR=%{_buildroot}

%clean
rm -rf ${_buildroot}

%files
%defattr(-,root,root)
%{_bindir}/rerun
%{_sysconfdir}/bash_completion.d/rerun
%{_datadir}/doc/rerun/AUTHORS
%{_datadir}/doc/rerun/ChangeLog
%{_datadir}/doc/rerun/COPYING
%{_datadir}/doc/rerun/INSTALL
%{_datadir}/doc/rerun/NEWS
%{_datadir}/doc/rerun/README
%{_datadir}/doc/rerun/README.md
%{_datadir}/rerun/modules/stubbs/bin/Markdown.pl
%{_datadir}/rerun/modules/stubbs/bin/roundup
%{_datadir}/rerun/modules/stubbs/bin/shocco
%{_datadir}/rerun/modules/stubbs/commands/add-command/metadata
%{_datadir}/rerun/modules/stubbs/commands/add-command/options.sh
%{_datadir}/rerun/modules/stubbs/commands/add-command/README.md
%{_datadir}/rerun/modules/stubbs/commands/add-command/script
%{_datadir}/rerun/modules/stubbs/commands/add-module/metadata
%{_datadir}/rerun/modules/stubbs/commands/add-module/README.md
%{_datadir}/rerun/modules/stubbs/commands/add-module/script
%{_datadir}/rerun/modules/stubbs/commands/add-option/metadata
%{_datadir}/rerun/modules/stubbs/commands/add-option/README.md
%{_datadir}/rerun/modules/stubbs/commands/add-option/script
%{_datadir}/rerun/modules/stubbs/commands/archive/metadata
%{_datadir}/rerun/modules/stubbs/commands/archive/options.sh
%{_datadir}/rerun/modules/stubbs/commands/archive/README.md
%{_datadir}/rerun/modules/stubbs/commands/archive/script
%{_datadir}/rerun/modules/stubbs/commands/docs/metadata
%{_datadir}/rerun/modules/stubbs/commands/docs/options.sh
%{_datadir}/rerun/modules/stubbs/commands/docs/README.md
%{_datadir}/rerun/modules/stubbs/commands/docs/script
%{_datadir}/rerun/modules/stubbs/commands/edit/metadata
%{_datadir}/rerun/modules/stubbs/commands/edit/README.md
%{_datadir}/rerun/modules/stubbs/commands/edit/script
%{_datadir}/rerun/modules/stubbs/commands/migrate/metadata
%{_datadir}/rerun/modules/stubbs/commands/migrate/options.sh
%{_datadir}/rerun/modules/stubbs/commands/migrate/README.md
%{_datadir}/rerun/modules/stubbs/commands/migrate/script
%{_datadir}/rerun/modules/stubbs/commands/rm-option/metadata
%{_datadir}/rerun/modules/stubbs/commands/rm-option/README.md
%{_datadir}/rerun/modules/stubbs/commands/rm-option/script
%{_datadir}/rerun/modules/stubbs/commands/test/metadata
%{_datadir}/rerun/modules/stubbs/commands/test/README.md
%{_datadir}/rerun/modules/stubbs/commands/test/script
%{_datadir}/rerun/modules/stubbs/lib/docs.css
%{_datadir}/rerun/modules/stubbs/lib/docs.sh
%{_datadir}/rerun/modules/stubbs/lib/functions.sh
%{_datadir}/rerun/modules/stubbs/lib/stub/bash/generate-options
%{_datadir}/rerun/modules/stubbs/lib/stub/bash/metadata
%{_datadir}/rerun/modules/stubbs/lib/stub/bash/templates/functions.sh
%{_datadir}/rerun/modules/stubbs/lib/stub/bash/templates/script
%{_datadir}/rerun/modules/stubbs/lib/stub/README.md
%{_datadir}/rerun/modules/stubbs/lib/test.sh
%{_datadir}/rerun/modules/stubbs/metadata
%{_datadir}/rerun/modules/stubbs/options/answers/metadata
%{_datadir}/rerun/modules/stubbs/options/answers/README.md
%{_datadir}/rerun/modules/stubbs/options/arg/metadata
%{_datadir}/rerun/modules/stubbs/options/arg/README.md
%{_datadir}/rerun/modules/stubbs/options/command/metadata
%{_datadir}/rerun/modules/stubbs/options/command/README.md
%{_datadir}/rerun/modules/stubbs/options/default/metadata
%{_datadir}/rerun/modules/stubbs/options/default/README.md
%{_datadir}/rerun/modules/stubbs/options/description/metadata
%{_datadir}/rerun/modules/stubbs/options/description/README.md
%{_datadir}/rerun/modules/stubbs/options/dir/metadata
%{_datadir}/rerun/modules/stubbs/options/dir/README.md
%{_datadir}/rerun/modules/stubbs/options/export/metadata
%{_datadir}/rerun/modules/stubbs/options/export/README.md
%{_datadir}/rerun/modules/stubbs/options/file/metadata
%{_datadir}/rerun/modules/stubbs/options/file/README.md
%{_datadir}/rerun/modules/stubbs/options/format/metadata
%{_datadir}/rerun/modules/stubbs/options/format/README.md
%{_datadir}/rerun/modules/stubbs/options/long/metadata
%{_datadir}/rerun/modules/stubbs/options/long/README.md
%{_datadir}/rerun/modules/stubbs/options/module/metadata
%{_datadir}/rerun/modules/stubbs/options/module/README.md
%{_datadir}/rerun/modules/stubbs/options/modules/metadata
%{_datadir}/rerun/modules/stubbs/options/modules/README.md
%{_datadir}/rerun/modules/stubbs/options/option/metadata
%{_datadir}/rerun/modules/stubbs/options/option/README.md
%{_datadir}/rerun/modules/stubbs/options/overwrite/metadata
%{_datadir}/rerun/modules/stubbs/options/overwrite/README.md
%{_datadir}/rerun/modules/stubbs/options/plan/metadata
%{_datadir}/rerun/modules/stubbs/options/plan/README.md
%{_datadir}/rerun/modules/stubbs/options/range/metadata
%{_datadir}/rerun/modules/stubbs/options/range/README.md
%{_datadir}/rerun/modules/stubbs/options/release/metadata
%{_datadir}/rerun/modules/stubbs/options/release/README.md
%{_datadir}/rerun/modules/stubbs/options/required/metadata
%{_datadir}/rerun/modules/stubbs/options/required/README.md
%{_datadir}/rerun/modules/stubbs/options/short/metadata
%{_datadir}/rerun/modules/stubbs/options/short/README.md
%{_datadir}/rerun/modules/stubbs/options/template/metadata
%{_datadir}/rerun/modules/stubbs/options/template/README.md
%{_datadir}/rerun/modules/stubbs/options/version/metadata
%{_datadir}/rerun/modules/stubbs/options/version/README.md
%{_datadir}/rerun/modules/stubbs/README.md
%{_datadir}/rerun/modules/stubbs/stubbs.1
%{_datadir}/rerun/modules/stubbs/templates/extract
%{_datadir}/rerun/modules/stubbs/templates/launcher
%{_datadir}/rerun/modules/stubbs/templates/rerun-module.spec
%{_datadir}/rerun/modules/stubbs/templates/test.functions.sh
%{_datadir}/rerun/modules/stubbs/templates/test.roundup
%{_datadir}/rerun/modules/stubbs/tests/add-command-1-test.sh
%{_datadir}/rerun/modules/stubbs/tests/add-module-1-test.sh
%{_datadir}/rerun/modules/stubbs/tests/add-option-1-test.sh
%{_datadir}/rerun/modules/stubbs/tests/archive-1-test.sh
%{_datadir}/rerun/modules/stubbs/tests/docs-1-test.sh
%{_datadir}/rerun/modules/stubbs/tests/functional-bash-1-test.sh
%{_datadir}/rerun/modules/stubbs/tests/migrate-1-test.sh
%{_datadir}/rerun/modules/stubbs/tests/rm-option-1-test.sh
%{_datadir}/rerun/modules/stubbs/tests/stubbs-functions-1-test.sh

%changelog

%pre

%post
