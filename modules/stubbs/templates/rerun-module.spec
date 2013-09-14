#
# Rerun module RPM specification file.
#
# This SPEC file is setup to be used by stubbs:archive which will supply values
# for %{module}, %{desc}, %{version} and %{requires} from the module metadata,
# and %{release} from the command line:
#

%ifos darwin
%define dist            .osx
%define _prefix         /opt/rerun
%define _sysconfdir     /opt/rerun/etc
%define _tmppath	%{_topdir}/tmp
%endif
%define moddir          %{_prefix}/lib/rerun/modules

Summary: Rerun %{module} module
Name: rerun-%{module}
Version: %{version}
Release: %{release}%{?dist}
Source: rerun-%{module}-%{version}.tar.gz
URL: http://rerun.github.com/rerun
Packager: rerun-discuss@googlegroups.com
 
# Redhat 5 needs this defined, not needed in later versions of RPM
# see http://fedoraproject.org/wiki/EPEL:Packaging#BuildRoot_tag
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

License: ASL 2.0
Group: Applications/System
# Disable automatic dependency discovery
AutoReqProv: no

Requires: %{requires}
Provides: rerun-%{module} = %{major}, rerun-%{module} = %{major}.%{minor}, rerun-%{module} = %{major}.%{minor}.%{revision}

# Disables debug packages and stripping of binaries:
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post %{nil}
# Use gzip compression for binary payload for better backwards compatible.
#   See: [#172](https://github.com/rerun/rerun/issues/172)
%define _binary_payload w0.gzdio

%description
%{desc}

%prep
%setup

%build
 
%install
echo "Building in: \"%{buildroot}\""
# Needed only for RH5
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{moddir}/%{module}
if [ ! -w "%{_builddir}/rerun-%{module}-%{version}/metadata" ]; then
  # this happens in distcheck phase of autoconf
  chmod -R u+w %{_builddir}/rerun-%{module}-%{version} %{_sourcedir}/rerun-%{module}-%{version}
fi
mv %{_builddir}/rerun-%{module}-%{version}/* %{buildroot}%{moddir}/%{module}

%clean
# Needed only for RH5
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{moddir}/%{module}
 
%changelog

%pre

%post
