#
# Rerun module RPM specification file.
#
# This SPEC file is setup to be used by stubbs:archive which will supply values
# for %{module}, %{desc}, %{version} and %{requires} from the module metadata,
# and %{release} from the command line:
#
Summary: Rerun %{module} module
Name: rerun-%{module}
Version: %{version}
Release: %{release}
 
License: ASL 2.0
Group: Applications/System

Source: rerun-%{module}-%{version}.tgz
Requires: %{requires}
Provides: rerun-%{module} = %{major}

# Disables debug packages and stripping of binaries:
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post %{nil}
 
%description
%{desc}

%prep

%setup

%build
 
%install
echo "Building in: \"%{buildroot}\""
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/usr/lib/rerun/modules/%{module}
mv %{_builddir}/rerun-%{module}-%{version}/* %{buildroot}/usr/lib/rerun/modules/%{module}

%clean

%files
%defattr(-,root,root)
/usr/lib/rerun/modules/%{module}
 
%changelog

%pre

%post
