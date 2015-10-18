---
title: Installing
submenu: downloads
---

Download/Install
================

If you are upgrading from an earlier version of FireHOL, you should
check if you will need to make any [configuration upgrades](/upgrade/).

If want an up to date version or cannot find a package for your
distribution, follow these steps:

-   [Download](#download)
-   [Verify](#verify)
-   [Install](#install)

Packages are available for many distributions, and are often a more
convenient way of installing FireHOL.

-   [Debian / Ubuntu installation](/installing/debian/)
-   [RedHat / CentOS installation](/installing/redhat/)
-   [Arch Linux installation](/installing/arch/)
-   [OpenWRT installation](/installing/openwrt/)

If you can provide improved instructions for existing or new
distributions, please [let us know](/source-install/#get-involved)
so we can add the information.


Download
--------

Our tar-files releases are provided compressed with gzip, bz2 and xz.
You only need one. If you don't know which compression your system can
handle, gzip (`.gz`{.filename} files) is certain to work, so the
examples assume you will choose that option.

You can choose to download one of the following:

-   [Latest stable release](/download/latest/)
-   [Pick from all releases](/download/releases/)
-   [Automatic daily build](/download/unsigned/master/)

The daily build is in fact even more up to date than its name suggests.
It rebuilds whenever a change is committed to the master branch of the
code. We take care to not break "master", so in general this build is
quite stable.

[Dependencies are listed at the
Wiki](https://github.com/firehol/firehol/wiki/Dependencies). FireHOL and
FireQOS detect at runtime if the commands they needs are installed. In
general the requirements are not onerous, just some common shell and
networking commands which come as standard with modern Linux
distributions.


Verify
------

All tar-files on the site come with MD5 (`.md5`{.filename}) and SHA512
(`.sha`{.filename}) checksums. To verify, download the checksum files as
well as the tar-file and run e.g.:

~~~~ {.programoutput}
$ md5sum -c firehol-2.0.0.tar.gz.md5 
firehol-2.0.0.tar.gz: OK
~~~~

or:

~~~~ {.programoutput}
$ sha512sum -c firehol-2.0.0.tar.gz.sha 
firehol-2.0.0.tar.gz: OK
~~~~

Official releases also come with [detached gpg
signatures](http://gnupg.org/gph/en/manual/x135.html) in the
`.asc`{.filename} files, they should have been created with one of these
keys:

-   Key ID
    [0xD829797E](http://pgp.mit.edu/pks/lookup?search=0xD829797E&op=index&fingerprint=on)\
    Fingerprint: 9CCE 9A8D 5328 FBD6 CE29 6DCC 63DF 1E44 D829 797E
-   Key ID
    [0xA8942A3D](http://pgp.mit.edu/pks/lookup?search=0xA8942A3D&op=index&fingerprint=on)\
    Fingerprint: 30A6 37E7 FB6A D149 741C A98B C630 FDD8 A894 2A3D

Initially your gpg keyring will not include these keys, so your first
time checking might go something like this:

~~~~ {.programoutput}
$ gpg --verify firehol-2.0.0.tar.gz.asc firehol-2.0.0.tar.gz
gpg: Signature made Sat 15 Feb 2014 12:19:56 GMT using RSA key ID D829797E
gpg: Can't check signature: public key not found

$ gpg --recv-keys D829797E
gpg: requesting key D829797E from hkp server keys.gnupg.net
gpg: /home/tmpu/.gnupg/trustdb.gpg: trustdb created
gpg: key D829797E: public key "Phil Whineray <phil@sanewall.org>" imported
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)

$ gpg --verify firehol-2.0.0.tar.gz.asc firehol-2.0.0.tar.gz
gpg: Signature made Sat 15 Feb 2014 12:19:56 GMT using RSA key ID D829797E
gpg: Good signature from "Phil Whineray <phil@sanewall.org>"
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 9CCE 9A8D 5328 FBD6 CE29  6DCC 63DF 1E44 D829 797E
~~~~

If you want to be certain you can trust the signature,
[contact us](/support/#email) and we will see what we can arrange.

Install
-------

Unpack and change directory with:

~~~~ {.programlisting}
tar xfz firehol-x.y.z.tar.gz
cd firehol-x.y.z
~~~~

Options for the `configure`{.command} program can be seen in the
`INSTALL`{.filename} file and by running:

~~~~ {.programlisting}
./configure --help
~~~~

To build and install taking the default options:

~~~~ {.programlisting}
./configure && make && sudo make install
~~~~

Alternatively, just copy the `sbin/firehol.in`{.filename} and
`sbin/fireqos.in`{.filename} files to where you want them.

All of the common SysVInit command line arguments are recognised by the
FireHOL and FireQOS scripts, which make them easy to deploy as startup
services. In many cases you can just copy or link them into the
appropriate folder.
