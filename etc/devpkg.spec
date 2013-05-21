#
# This is a package used by the development team to assist 
# users who use OS's that are RPM based but don't have rerun 
# provided by the OS team's YUM repos.  
#

# this seems to get rpm working on OSX with rpm 5.1.9
%ifos darwin
%define dist		.osx
%define _prefix		/opt/rerun
%define _sysconfdir	/opt/rerun/etc
%endif
%define moddir		%{_prefix}/lib/rerun/modules/stubbs

Name: rerun
Summary: Rerun is a structured approach to bash scripting
Version: %{version}
Release: %{release}%{?dist}
Source0: rerun-%{version}.tar.gz
URL: http://rerun.github.com/rerun
Packager: rerun-discuss@googlegroups.com

License: ASL 2.0
Group: Applications/System
# Disable automatic dependency discovery
AutoReqProv: no
#   Removing dependency on bash just in case some distro provides
#   somthing like bash4...
#Requires: bash
%ifos darwin
Provides: /bin/sh, rerun = %{major}, rerun = %{major}.%{minor}, rerun = %{major}.%{minor}.%{revision}
%else
Provides: rerun = %{major}, rerun = %{major}.%{minor}, rerun = %{major}.%{minor}.%{revision}
%endif
# Disables debug packages and stripping of binaries:
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post %{nil}

# Crank up the compression
%define _binary_payload w0.gzdio


%description
A simple command runner because it's easy to forget standard operating procedure.

%prep
%setup

%build
./configure --prefix=%{_prefix} --sysconfdir=%{_sysconfdir}
make

%install
echo "Installing to: \"${buildroot}\""
make install DESTDIR=%{buildroot}
# TODO: remove after issue 147 fixed
chmod 777 %{buildroot}%{_prefix}/lib/rerun/modules %{buildroot}%{moddir}/tests

%clean
rm -rf ${buildroot}

%files
%defattr(-,root,root,-)
# TODO: these need to be 755 after bug 147 is fixed
%dir %{_prefix}/lib/rerun/modules
%dir %{_prefix}/lib/rerun/modules/stubbs/tests
%{_bindir}/rerun
%{_sysconfdir}/bash_completion.d/rerun
%{_datadir}/doc/rerun/AUTHORS
%{_datadir}/doc/rerun/ChangeLog
%{_datadir}/doc/rerun/COPYING
%{_datadir}/doc/rerun/INSTALL
%{_datadir}/doc/rerun/NEWS
%{_datadir}/doc/rerun/README
%{_datadir}/doc/rerun/README.md
%{moddir}/bin/Markdown.pl
%{moddir}/bin/roundup
%{moddir}/bin/shocco
%{moddir}/commands/add-command/metadata
%{moddir}/commands/add-command/options.sh
%{moddir}/commands/add-command/README.md
%{moddir}/commands/add-command/script
%{moddir}/commands/add-module/metadata
%{moddir}/commands/add-module/README.md
%{moddir}/commands/add-module/script
%{moddir}/commands/add-option/metadata
%{moddir}/commands/add-option/README.md
%{moddir}/commands/add-option/script
%{moddir}/commands/archive/metadata
%{moddir}/commands/archive/options.sh
%{moddir}/commands/archive/README.md
%{moddir}/commands/archive/script
%{moddir}/commands/docs/metadata
%{moddir}/commands/docs/options.sh
%{moddir}/commands/docs/README.md
%{moddir}/commands/docs/script
%{moddir}/commands/edit/metadata
%{moddir}/commands/edit/README.md
%{moddir}/commands/edit/script
%{moddir}/commands/migrate/metadata
%{moddir}/commands/migrate/options.sh
%{moddir}/commands/migrate/README.md
%{moddir}/commands/migrate/script
%{moddir}/commands/rm-option/metadata
%{moddir}/commands/rm-option/README.md
%{moddir}/commands/rm-option/script
%{moddir}/commands/test/metadata
%{moddir}/commands/test/README.md
%{moddir}/commands/test/script
%{moddir}/lib/docs.css
%{moddir}/lib/docs.sh
%{moddir}/lib/functions.sh
%{moddir}/lib/stub/bash/generate-options
%{moddir}/lib/stub/bash/metadata
%{moddir}/lib/stub/bash/templates/functions.sh
%{moddir}/lib/stub/bash/templates/script
%{moddir}/lib/stub/README.md
%{moddir}/lib/test.sh
%{moddir}/metadata
%{moddir}/options/answers/metadata
%{moddir}/options/answers/README.md
%{moddir}/options/arg/metadata
%{moddir}/options/arg/README.md
%{moddir}/options/command/metadata
%{moddir}/options/command/README.md
%{moddir}/options/default/metadata
%{moddir}/options/default/README.md
%{moddir}/options/description/metadata
%{moddir}/options/description/README.md
%{moddir}/options/dir/metadata
%{moddir}/options/dir/README.md
%{moddir}/options/export/metadata
%{moddir}/options/export/README.md
%{moddir}/options/file/metadata
%{moddir}/options/file/README.md
%{moddir}/options/format/metadata
%{moddir}/options/format/README.md
%{moddir}/options/long/metadata
%{moddir}/options/long/README.md
%{moddir}/options/module/metadata
%{moddir}/options/module/README.md
%{moddir}/options/modules/metadata
%{moddir}/options/modules/README.md
%{moddir}/options/option/metadata
%{moddir}/options/option/README.md
%{moddir}/options/overwrite/metadata
%{moddir}/options/overwrite/README.md
%{moddir}/options/plan/metadata
%{moddir}/options/plan/README.md
%{moddir}/options/range/metadata
%{moddir}/options/range/README.md
%{moddir}/options/release/metadata
%{moddir}/options/release/README.md
%{moddir}/options/required/metadata
%{moddir}/options/required/README.md
%{moddir}/options/short/metadata
%{moddir}/options/short/README.md
%{moddir}/options/template/metadata
%{moddir}/options/template/README.md
%{moddir}/options/version/metadata
%{moddir}/options/version/README.md
%{moddir}/README.md
%{moddir}/stubbs.1
%{moddir}/templates/extract
%{moddir}/templates/launcher
%{moddir}/templates/rerun-module.spec
%{moddir}/templates/test.functions.sh
%{moddir}/templates/test.roundup
%{moddir}/tests/add-command-1-test.sh
%{moddir}/tests/add-module-1-test.sh
%{moddir}/tests/add-option-1-test.sh
%{moddir}/tests/archive-1-test.sh
%{moddir}/tests/docs-1-test.sh
%{moddir}/tests/functional-bash-1-test.sh
%{moddir}/tests/migrate-1-test.sh
%{moddir}/tests/rm-option-1-test.sh
%{moddir}/tests/stubbs-functions-1-test.sh
%{_libexecdir}/rerun/tests/functions.sh
%{_libexecdir}/rerun/tests/rerun-0-test.sh
%{_libexecdir}/rerun/tests/rerun-1-test.sh
%{_libexecdir}/rerun/tests/rerun-2-test.sh
%{_libexecdir}/rerun/tests/rerun-4-test.sh

%ifos darwin
%dir /
%dir /opt
%dir %{_prefix}
%dir %{_prefix}/bin
%dir %{_prefix}/etc
%dir %{_prefix}/etc/bash_completion.d
%dir %{_prefix}/lib
%dir %{_prefix}/lib/rerun
%dir %{_prefix}/lib/rerun/modules/stubbs
%dir %{_prefix}/lib/rerun/modules/stubbs/bin
%dir %{_prefix}/lib/rerun/modules/stubbs/commands
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/add-command
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/add-module
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/add-option
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/archive
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/docs
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/edit
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/migrate
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/rm-option
%dir %{_prefix}/lib/rerun/modules/stubbs/commands/test
%dir %{_prefix}/lib/rerun/modules/stubbs/lib
%dir %{_prefix}/lib/rerun/modules/stubbs/lib/stub
%dir %{_prefix}/lib/rerun/modules/stubbs/lib/stub/bash
%dir %{_prefix}/lib/rerun/modules/stubbs/lib/stub/bash/templates
%dir %{_prefix}/lib/rerun/modules/stubbs/options
%dir %{_prefix}/lib/rerun/modules/stubbs/options/answers
%dir %{_prefix}/lib/rerun/modules/stubbs/options/arg
%dir %{_prefix}/lib/rerun/modules/stubbs/options/command
%dir %{_prefix}/lib/rerun/modules/stubbs/options/default
%dir %{_prefix}/lib/rerun/modules/stubbs/options/description
%dir %{_prefix}/lib/rerun/modules/stubbs/options/dir
%dir %{_prefix}/lib/rerun/modules/stubbs/options/export
%dir %{_prefix}/lib/rerun/modules/stubbs/options/file
%dir %{_prefix}/lib/rerun/modules/stubbs/options/format
%dir %{_prefix}/lib/rerun/modules/stubbs/options/long
%dir %{_prefix}/lib/rerun/modules/stubbs/options/module
%dir %{_prefix}/lib/rerun/modules/stubbs/options/modules
%dir %{_prefix}/lib/rerun/modules/stubbs/options/option
%dir %{_prefix}/lib/rerun/modules/stubbs/options/overwrite
%dir %{_prefix}/lib/rerun/modules/stubbs/options/plan
%dir %{_prefix}/lib/rerun/modules/stubbs/options/range
%dir %{_prefix}/lib/rerun/modules/stubbs/options/release
%dir %{_prefix}/lib/rerun/modules/stubbs/options/required
%dir %{_prefix}/lib/rerun/modules/stubbs/options/short
%dir %{_prefix}/lib/rerun/modules/stubbs/options/template
%dir %{_prefix}/lib/rerun/modules/stubbs/options/version
%dir %{_prefix}/lib/rerun/modules/stubbs/templates
%dir %{_prefix}/libexec
%dir %{_prefix}/libexec/rerun
%dir %{_prefix}/libexec/rerun/tests
%dir %{_prefix}/share
%dir %{_prefix}/share/doc
%dir %{_prefix}/share/doc/rerun
%endif

%changelog

%pre

%post
