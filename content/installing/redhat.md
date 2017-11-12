---
title: RedHat/CentOS installation
submenu: downloads
---

RedHat/CentOS installation
==========================

Newer versions of RedHat do not carry the FireHOL packages because there
is no packager. If you want to help that effort, these links might help:

* [Existing pkgdb entry](https://admin.fedoraproject.org/pkgdb/package/rpms/firehol/)
* [Wiki page on joining the maintainers](https://fedoraproject.org/wiki/Join_the_package_collection_maintainers)

As a result we make a best-effort attempt to
[build suitables RPMS](https://github.com/firehol/packages), so
you can always
[download the latest](https://github.com/firehol/packages/releases/latest).

To install on CentOS 7 / RHEL7:

~~~~ {.programlisting}
yum --nogpgcheck localinstall iprange-x.y.z-1.el7.centos.x86_64.rpm
yum --nogpgcheck localinstall firehol-x.y.z-1.el7.centos.noarch.rpm
~~~~
