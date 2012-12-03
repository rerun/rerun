#
# This SPEC file is setup to by used as follows:
#
#
#
Summary: Dance your way through standard operating procedure
Name: rerun
Version: %{version}
Release: %{release}
Source0: rerun-%{version}.zip
URL: http://rerun.github.com/rerun
 
License: ASL 2.0
Group: Applications/System
Requires: bash
Provides: rerun = %{major}, rerun = %{major}.%{minor}, rerun = %{major}.%{minor}.%{revision}

# Disables debug packages and stripping of binaries:
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post %{nil}
 
%description
A simple command runner because it's easy to forget standard operating procedure.
 
%prep

%setup

%build
 
%install
echo "Building in: \"%{buildroot}\""
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/usr/bin
mv %{_builddir}/rerun-%{version}/rerun %{buildroot}/usr/bin
install -d -m 755 %{buildroot}/etc/rerun
mv %{_builddir}/rerun-%{version}/bash_completion.sh %{buildroot}/etc/rerun
install -d -m 755 %{buildroot}/usr/lib/rerun
mv %{_builddir}/rerun-%{version}/modules %{buildroot}/usr/lib/rerun/modules

%clean

%files
%defattr(-,root,root)
/etc/rerun
/usr/bin/rerun
/usr/lib/rerun
 
%changelog

%pre

%post
