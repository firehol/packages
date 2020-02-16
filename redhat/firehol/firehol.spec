Name:           firehol
Version:        <<VER>>
Release:        1%{?dist}
Summary:        Simple and powerful firewall and traffic shaping languages
License:        GPLv2+
URL:            http://firehol.org
Source0:        <<URL>>/firehol-%{version}.tar.bz2
%if 0%{?rhel} > 0 && 0%{?rhel} < 7
Source1:        firehol.init
Source2:        fireqos.init
%else
Source1:        firehol.service
Source2:        fireqos.service
%endif
BuildArch:      noarch
BuildRequires:  iprange
BuildRequires:  iproute
BuildRequires:  ipset
BuildRequires:  iptables
BuildRequires:  iptables-ipv6
BuildRequires:  tcpdump
%if 0%{?rhel} > 0 && 0%{?rhel} < 7
%else
BuildRequires:  systemd
%endif
Requires:       coreutils
Requires:       gawk
Requires:       grep
Requires:       gzip
Requires:       ipset
Requires:       iproute
Requires:       iptables
Requires:       iptables-ipv6
Requires:       less
Requires:       sed
Requires:       util-linux
Requires:       tcpdump
%if 0%{?rhel} > 0 && 0%{?rhel} < 7
Requires:       module-init-tools
%else
Requires:       kmod
Requires(post):  systemd
Requires(preun):  systemd
Requires(postun):  systemd
%endif

%description
FireHOL is a generic firewall generator, meaning that you can design any kind
of local or routing stateful packet filtering firewalls with ease. Install
FireHOL if you want an easy way to configure stateful packet filtering
firewalls on Linux hosts and routers.

FireHOL uses an extremely simple but powerful way to define firewall rules
which it turns into complete stateful iptables firewalls.

You can run FireHOL with the 'helpme' argument, to get a configuration
file for the system run, which you can modify according to your
needs. The default configuration file will allow only client traffic
on all interfaces.

%prep
%setup -q

%build
%configure \
	--disable-link-balancer \
	--disable-vnetbuild
make %{?_smp_mflags}

%install
rm -rf "%{buildroot}"
make %{?_smp_mflags} install DESTDIR="%{buildroot}"
# Fixup the symlinks manually
rm %{buildroot}/usr/sbin/firehol
rm %{buildroot}/usr/sbin/fireqos
rm %{buildroot}/usr/sbin/update-ipsets
ln -s %{_libexecdir}/firehol/%{version}/firehol %{buildroot}/usr/sbin
ln -s %{_libexecdir}/firehol/%{version}/fireqos %{buildroot}/usr/sbin
ln -s %{_libexecdir}/firehol/%{version}/update-ipsets %{buildroot}/usr/sbin

%if 0%{?rhel} > 0 && 0%{?rhel} < 7
mkdir -p %{buildroot}%{_initrddir}
install -pm755 %{S:1} %{buildroot}%{_initrddir}/firehol
install -pm755 %{S:2} %{buildroot}%{_initrddir}/fireqos
%else
# Install systemd units.
mkdir -p %{buildroot}%{_unitdir}
install -pm644 %{S:1} %{S:2} %{buildroot}%{_unitdir}
%endif

# Install runtime directories.
mkdir -p %{buildroot}%{_sysconfdir}/firehol/services
mkdir -p %{buildroot}%{_localstatedir}/spool/firehol

# Ghost configurations.
touch %{buildroot}%{_sysconfdir}/firehol/firehol.conf \
      %{buildroot}%{_sysconfdir}/firehol/fireqos.conf

%post
%if 0%{?rhel} > 0 && 0%{?rhel} < 7
/sbin/chkconfig --add firehol
/sbin/chkconfig --add fireqos
%else
%systemd_post firehol.service
%systemd_post fireqos.service
%endif

%preun
%if 0%{?rhel} > 0 && 0%{?rhel} < 7
if [ $1 = 0 ] ; then
	/sbin/service firehol stop >/dev/null 2>&1
	/sbin/service fireqos stop >/dev/null 2>&1
	/sbin/chkconfig --del firehol
	/sbin/chkconfig --del fireqos
fi
%else
%systemd_preun firehol.service
%systemd_preun fireqos.service
%endif

%postun
%if 0%{?rhel} > 0 && 0%{?rhel} < 7
if [ "$1" -ge "1" ] ; then
        /sbin/service firehol condrestart >/dev/null 2>&1 || :
        /sbin/service fireqos condrestart >/dev/null 2>&1 || :
fi
%else
%systemd_postun_with_restart firehol.service
%systemd_postun_with_restart fireqos.service
%endif

%files
%doc README THANKS examples contrib
%doc doc/firehol
%doc doc/fireqos
%dir %{_sysconfdir}/firehol
%config(noreplace) %{_sysconfdir}/firehol/firehol.conf
%config(noreplace) %{_sysconfdir}/firehol/fireqos.conf
%{_sysconfdir}/firehol/firehol.conf.example
%{_sysconfdir}/firehol/fireqos.conf.example
%{_sysconfdir}/firehol/services/bittorrent.conf.example
%if 0%{?rhel} > 0 && 0%{?rhel} < 7
%{_initrddir}/firehol
%{_initrddir}/fireqos
%else
%{_unitdir}/firehol.service
%{_unitdir}/fireqos.service
%endif
%{_sbindir}/firehol
%{_sbindir}/fireqos
%{_sbindir}/update-ipsets
%{_docdir}/firehol/html/*
%{_docdir}/firehol/contrib/*
%{_docdir}/firehol/examples/*
%{_docdir}/firehol/*.pdf
%{_mandir}/man1/*.1*
%{_mandir}/man5/*.5*
%{_datadir}/update-ipsets/webdir/*
%dir %{_sysconfdir}/firehol/services/
%{_localstatedir}/spool/firehol
%{_libexecdir}/firehol/%{version}/firehol
%{_libexecdir}/firehol/%{version}/fireqos
%{_libexecdir}/firehol/%{version}/update-ipsets
%{_libexecdir}/firehol/%{version}/functions.common
%{_libexecdir}/firehol/%{version}/install.config
%{_libexecdir}/firehol/%{version}/services.common
%{_libexecdir}/firehol/%{version}/services.firehol
%{_libexecdir}/firehol/%{version}/services.fireqos

%changelog
* Sat Feb 15 2020 John Ramsden <johnramsden@riseup.net>
- Enable update-ipsets
* Thu Jan 19 2017 Phil Whineray <phil@firehol.org> - 3.1.1-1
- Imported from final RedHat version, updated for v3.1.1 package
