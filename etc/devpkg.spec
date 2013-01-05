#
# This is a package used by the development team to assist 
# users who use OS's that are RPM based but don't have rerun 
# provided by the OS team's YUM repos.  
#
Summary: Dance your way through standard operating procedure
Name: rerun
Version: %{version}
Release: %{release}%{?dist}
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
./configure --prefix=/usr --sysconfdir=/etc
make

%install
echo "Installing to: \"${buildroot}\""
make install DESTDIR=%{buildroot}

%clean
rm -rf ${buildroot}

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
%{_libdir}/rerun/modules/stubbs/bin/Markdown.pl
%{_libdir}/rerun/modules/stubbs/bin/roundup
%{_libdir}/rerun/modules/stubbs/bin/shocco
%{_libdir}/rerun/modules/stubbs/commands/add-command/metadata
%{_libdir}/rerun/modules/stubbs/commands/add-command/options.sh
%{_libdir}/rerun/modules/stubbs/commands/add-command/README.md
%{_libdir}/rerun/modules/stubbs/commands/add-command/script
%{_libdir}/rerun/modules/stubbs/commands/add-module/metadata
%{_libdir}/rerun/modules/stubbs/commands/add-module/README.md
%{_libdir}/rerun/modules/stubbs/commands/add-module/script
%{_libdir}/rerun/modules/stubbs/commands/add-option/metadata
%{_libdir}/rerun/modules/stubbs/commands/add-option/README.md
%{_libdir}/rerun/modules/stubbs/commands/add-option/script
%{_libdir}/rerun/modules/stubbs/commands/archive/metadata
%{_libdir}/rerun/modules/stubbs/commands/archive/options.sh
%{_libdir}/rerun/modules/stubbs/commands/archive/README.md
%{_libdir}/rerun/modules/stubbs/commands/archive/script
%{_libdir}/rerun/modules/stubbs/commands/docs/metadata
%{_libdir}/rerun/modules/stubbs/commands/docs/options.sh
%{_libdir}/rerun/modules/stubbs/commands/docs/README.md
%{_libdir}/rerun/modules/stubbs/commands/docs/script
%{_libdir}/rerun/modules/stubbs/commands/edit/metadata
%{_libdir}/rerun/modules/stubbs/commands/edit/README.md
%{_libdir}/rerun/modules/stubbs/commands/edit/script
%{_libdir}/rerun/modules/stubbs/commands/migrate/metadata
%{_libdir}/rerun/modules/stubbs/commands/migrate/options.sh
%{_libdir}/rerun/modules/stubbs/commands/migrate/README.md
%{_libdir}/rerun/modules/stubbs/commands/migrate/script
%{_libdir}/rerun/modules/stubbs/commands/rm-option/metadata
%{_libdir}/rerun/modules/stubbs/commands/rm-option/README.md
%{_libdir}/rerun/modules/stubbs/commands/rm-option/script
%{_libdir}/rerun/modules/stubbs/commands/test/metadata
%{_libdir}/rerun/modules/stubbs/commands/test/README.md
%{_libdir}/rerun/modules/stubbs/commands/test/script
%{_libdir}/rerun/modules/stubbs/lib/docs.css
%{_libdir}/rerun/modules/stubbs/lib/docs.sh
%{_libdir}/rerun/modules/stubbs/lib/functions.sh
%{_libdir}/rerun/modules/stubbs/lib/stub/bash/generate-options
%{_libdir}/rerun/modules/stubbs/lib/stub/bash/metadata
%{_libdir}/rerun/modules/stubbs/lib/stub/bash/templates/functions.sh
%{_libdir}/rerun/modules/stubbs/lib/stub/bash/templates/script
%{_libdir}/rerun/modules/stubbs/lib/stub/README.md
%{_libdir}/rerun/modules/stubbs/lib/test.sh
%{_libdir}/rerun/modules/stubbs/metadata
%{_libdir}/rerun/modules/stubbs/options/answers/metadata
%{_libdir}/rerun/modules/stubbs/options/answers/README.md
%{_libdir}/rerun/modules/stubbs/options/arg/metadata
%{_libdir}/rerun/modules/stubbs/options/arg/README.md
%{_libdir}/rerun/modules/stubbs/options/command/metadata
%{_libdir}/rerun/modules/stubbs/options/command/README.md
%{_libdir}/rerun/modules/stubbs/options/default/metadata
%{_libdir}/rerun/modules/stubbs/options/default/README.md
%{_libdir}/rerun/modules/stubbs/options/description/metadata
%{_libdir}/rerun/modules/stubbs/options/description/README.md
%{_libdir}/rerun/modules/stubbs/options/dir/metadata
%{_libdir}/rerun/modules/stubbs/options/dir/README.md
%{_libdir}/rerun/modules/stubbs/options/export/metadata
%{_libdir}/rerun/modules/stubbs/options/export/README.md
%{_libdir}/rerun/modules/stubbs/options/file/metadata
%{_libdir}/rerun/modules/stubbs/options/file/README.md
%{_libdir}/rerun/modules/stubbs/options/format/metadata
%{_libdir}/rerun/modules/stubbs/options/format/README.md
%{_libdir}/rerun/modules/stubbs/options/long/metadata
%{_libdir}/rerun/modules/stubbs/options/long/README.md
%{_libdir}/rerun/modules/stubbs/options/module/metadata
%{_libdir}/rerun/modules/stubbs/options/module/README.md
%{_libdir}/rerun/modules/stubbs/options/modules/metadata
%{_libdir}/rerun/modules/stubbs/options/modules/README.md
%{_libdir}/rerun/modules/stubbs/options/option/metadata
%{_libdir}/rerun/modules/stubbs/options/option/README.md
%{_libdir}/rerun/modules/stubbs/options/overwrite/metadata
%{_libdir}/rerun/modules/stubbs/options/overwrite/README.md
%{_libdir}/rerun/modules/stubbs/options/plan/metadata
%{_libdir}/rerun/modules/stubbs/options/plan/README.md
%{_libdir}/rerun/modules/stubbs/options/range/metadata
%{_libdir}/rerun/modules/stubbs/options/range/README.md
%{_libdir}/rerun/modules/stubbs/options/release/metadata
%{_libdir}/rerun/modules/stubbs/options/release/README.md
%{_libdir}/rerun/modules/stubbs/options/required/metadata
%{_libdir}/rerun/modules/stubbs/options/required/README.md
%{_libdir}/rerun/modules/stubbs/options/short/metadata
%{_libdir}/rerun/modules/stubbs/options/short/README.md
%{_libdir}/rerun/modules/stubbs/options/template/metadata
%{_libdir}/rerun/modules/stubbs/options/template/README.md
%{_libdir}/rerun/modules/stubbs/options/version/metadata
%{_libdir}/rerun/modules/stubbs/options/version/README.md
%{_libdir}/rerun/modules/stubbs/README.md
%{_libdir}/rerun/modules/stubbs/stubbs.1
%{_libdir}/rerun/modules/stubbs/templates/extract
%{_libdir}/rerun/modules/stubbs/templates/launcher
%{_libdir}/rerun/modules/stubbs/templates/rerun-module.spec.txt
%{_libdir}/rerun/modules/stubbs/templates/test.functions.sh
%{_libdir}/rerun/modules/stubbs/templates/test.roundup
%{_libdir}/rerun/modules/stubbs/tests/add-command-1-test.sh
%{_libdir}/rerun/modules/stubbs/tests/add-module-1-test.sh
%{_libdir}/rerun/modules/stubbs/tests/add-option-1-test.sh
%{_libdir}/rerun/modules/stubbs/tests/archive-1-test.sh
%{_libdir}/rerun/modules/stubbs/tests/docs-1-test.sh
%{_libdir}/rerun/modules/stubbs/tests/functional-bash-1-test.sh
%{_libdir}/rerun/modules/stubbs/tests/migrate-1-test.sh
%{_libdir}/rerun/modules/stubbs/tests/rm-option-1-test.sh
%{_libdir}/rerun/modules/stubbs/tests/stubbs-functions-1-test.sh
%{_libexecdir}/rerun/tests/functions.sh
%{_libexecdir}/rerun/tests/rerun-0-test.sh
%{_libexecdir}/rerun/tests/rerun-1-test.sh
%{_libexecdir}/rerun/tests/rerun-2-test.sh
%{_libexecdir}/rerun/tests/rerun-3-test.sh
%{_libexecdir}/rerun/tests/rerun-4-test.sh

%changelog

%pre

%post
