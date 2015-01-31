---
title: FireHOL Source Code
submenu: source
---

FireHOL Source Code
===================

All of FireHOL is made available under the [GPLv2+
Licence](http://www.gnu.org/licenses/gpl-2.0.html). To make use of the
sources, you need to:

-   [Download](#download) from the repository
-   [Build](#build) the package

Note that versions checked out from git will use internal version
numbers e.g.:

~~~~ {.programoutput}
$ ./sbin/fireqos.in
FireQOS $Id: def55bbc9c2a78aef580e88ad6d3f9ba689a6004 $
~~~~

If you want a real version number you should [download and install a
packaged version](/installing/).

Download
--------

You can download or clone the source from our [GitHub
repository](https://github.com/ktsaou/firehol). The basic
`git`{.command} commands to perform a clone are below. We also have
GitHub repositories for [this
website](https://github.com/philwhineray/firehol-website) and our
[build/release
infrastructure](https://github.com/philwhineray/firehol-infrastructure).

Note: if you do not want to run `git`{.command} but are just looking for
the bleeding edge version, you can still use the [normal install
instructions](/installing): the ['daily
build'](/download/unsigned/master) is actually updated automatically
whenever the master repository is changed, within a few minutes.

For a first time clone of a repository into directory
`firehol`{.filename}:

~~~~ {.programlisting}
$ git clone https://github.com/ktsaou/firehol.git
Cloning into 'firehol'...
remote: Reusing existing pack: 4651, done.
remote: Counting objects: 20, done.
remote: Compressing objects: 100% (15/15), done.
remote: Total 4671 (delta 5), reused 20 (delta 5)
Receiving objects: 100% (4671/4671), 1.80 MiB | 714 KiB/s, done.
Resolving deltas: 100% (3008/3008), done.
$ cd firehol
~~~~

Update a previously cloned repository to the latest version:

~~~~ {.programlisting}
$ cd firehol
$ git pull
Already up-to-date.
~~~~

If you have successfully checked out the sources, you should be able to
run the scripts as `sudo ./sbin/firehol.in`{.command} and
`sudo ./sbin/fireqos.in`{.command} to get basic help information.

~~~~ {.programlisting}
$ sudo ./sbin/firehol.in
FireHOL $Id: 483e51d16996e3b78c7c3df15058ef0f03a4408a $
(C) Copyright 2003-2013 Costa Tsaousis <costa@tsaousis.gr>
(C) Copyright 2012-2013 Phil Whineray <phil@firehol.org>
FireHOL is distributed under the GPL v2+.
Home Page: http://firehol.org

-------------------------------------------------------------------------
Get notified of new FireHOL releases by subscribing to the mailing list:
    http://lists.firehol.org/mailman/listinfo/firehol-support/
-------------------------------------------------------------------------

FireHOL supports the following command line arguments (only one of them):

    start       to activate the firewall configuration.
  ...

$ sudo ./sbin/fireqos.in
FireQOS $Id: 41004cd0a5f6c3a3bfa0beb67c3bdcb2ecf1a3fe $
(C) 2013 Costa Tsaousis, GPL

./sbin/fireqos.in action

action can be one of:

    start [filename] [-- options]
        or
    [filename] start [-- options]
  ...
~~~~

For more help with git, you should read one of the many tutorials that
can be found. [This
one](http://www.vogella.com/tutorials/Git/article.html) looks very
comprehensive. There is also an online version of what you get by
running [man gittutorial](http://git-scm.com/docs/gittutorial).

Build From Source
-----------------

FireHOL and FireQOS are
[Bash](http://www.gnu.org/software/bash/bash.html) scripts. As such you
don't need to do a build to use them. If you are not packaging a release
you can just copy and/or use `sbin/firehol.in`{.filename} and
`sbin/fireqos.in`{.filename} directly.

To build the documentation and/or a tar-file, you will need:

-   [pandoc 1.9.4.2 or
    higher](http://johnmacfarlane.net/pandoc/installing.html)
-   [pdflatex from e.g. TeX
    Live](https://www.tug.org/texlive/pkginstall.html)
-   [GNU autoconf](http://www.gnu.org/software/autoconf/)
-   [GNU automake](http://www.gnu.org/software/automake/)

If you are building from a git repository, a complete clean of your tree
and build of a firehol-development-tar.gz can be done by running:

~~~~ {.programlisting}
./packaging/git-build
~~~~

The key steps of creating Makefiles, enabling build of the manual and
producing the outputs work from both a repository or an unpacked source
tar-file. Use these commands:

~~~~ {.programlisting}
./autogen.sh
./configure --enable-maintainer-mode
make
~~~~
