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
 
License: LGPL
Group: Applications/System

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
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/usr/bin
mv %{_builddir}/rerun-%{version}/rerun %{buildroot}/usr/bin
install -d -m 755 %{buildroot}/usr/lib/rerun
mv %{_builddir}/rerun-%{version}/modules %{buildroot}/usr/lib/rerun/modules

%clean

%files
%defattr(-,root,root)
/
 
%changelog

%pre

%post
