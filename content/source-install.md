---
title: FireHOL Source Code
submenu: source
---

FireHOL Source Code
===================

All of FireHOL is made available under the [GPLv2+
Licence](http://www.gnu.org/licenses/gpl-2.0.html). To make use of the
sources, you need to:

-   [Download](#download) from the [repository](https://github.com/firehol/firehol)
-   [Build](https://github.com/firehol/firehol/#git) the package
-   Developers and non-developers alike are welcome
    to [get involved](#get-involved) in the FireHOL project

Download
--------

Unless you want to help develop FireHOL you may want to [download and install a
packaged version](/installing/).

You can download or clone the source from our [GitHub
repository](https://github.com/firehol/firehol). The basic
`git`{.command} commands to perform a clone are below. We also have
GitHub repositories for [this
website](https://github.com/firehol/firehol-website) and our
[build/release
infrastructure](https://github.com/firehol/firehol-infrastructure).

Note: if you do not want to run `git`{.command} but are just looking for
the bleeding edge version, you can still use the [normal install
instructions](/installing/): the ['daily
build'](/download/unsigned/master/) is actually updated automatically
whenever the master repository is changed, within a few minutes.

For a first time clone of a repository into directory
`firehol`{.filename}:

~~~~ {.programlisting}
$ git clone https://github.com/firehol/firehol.git
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


Get Involved
------------

Help on the project will be welcomed in any area you have the time and
inclination to offer it. One-off reports and offers of help are perfectly
welcome if you spot a problem in the code, documentation or website.

If you would like to help out but don't know exactly what on,
please consider introducing yourself on the [development mailing
list](http://lists.firehol.org/mailman/listinfo/firehol-devs)
([archive](http://lists.firehol.org/pipermail/firehol-devs/)).

Development decisions take place using a combination of the development
list and the [GitHub issue tracker](https://github.com/firehol/firehol/issues).

Developers
:   Core development requires you to understand
    [BASH](http://www.gnu.org/software/bash/bash.html) reasonably well.
    It will help if you know [git](http://git-scm.com/) and
    have a [github account](https://github.com/) but if you want to
    post patches or even code snippets, that's fine too.

    To get coding, fork the [repository](https://github.com/firehol/firehol),
    which doesn't require you to have an account,
    and see the [build instructions](#build-from-source).

    To help with the build/release system, take a look at its
    [repository](https://github.com/philwhineray/firehol-infrastructure).

    To learn [Bash](http://www.gnu.org/software/bash/bash.html) scripting we
    suggest the following documents:

    -   [Advanced Bash-Scripting
        Guide](http://www.tldp.org/LDP/abs/html/index.html)
    -   [Bash Programming - Introduction
        HOW-TO](http://www.tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html) (older)

Testers
:   Should have a good understanding of the tools needed to check
    if a firewall is behaving as they expect. General systems
    admin knowledge will be helpful as will understanding plain iptables
    commands.

    You don't need in-depth knowledge or to be able to test everything
    to be useful - every little helps. If many people check just their
    running setup against the [daily build](/download/unsigned/master/)
    regularly, we could be reasonably sure that nothing will break
    when we do a release.

Documentation writers + Website designers
:   Documentation and website pages are all processed with [pandoc
    markdown](http://johnmacfarlane.net/pandoc/README.html#pandocs-markdown)
    which is very quick and easy to use.

    Manual page updates are all about spotting errors in the current
    files or tracking changes and additions in the
    [code repository](https://github.com/firehol/firehol).

    There is a lot of scope for new [website
    guides](/documentation/#guides-and-tutorials) to walk users through
    setting up firewalling and traffic control. Some ideas:

    -   Basic host protection
    -   Single network protection
    -   Multiple network / DMZ protection
    -   Network Address Translation (NAT) and masquerading
    -   Embedding iptables commands
    -   Unusual traffic
    -   Tarpitting
    -   Logging
    -   Basic QOS traffic matching
    -   Advanced QOS traffic matching
    -   Overhead calculation for QOS

    If you have installed FireHOL on a platform other than
    the ones [listed](/installing/), a quick set of instructions
    can help many people.

    The [website source](https://github.com/philwhineray/firehol-website)
    is compiled with [nanoc](http://nanoc.ws/install/) and uses
    [bootstrap](http://getbootstrap.com/) for styling.

Support and Helping Others
:   If you are an experienced user willing to help others, please join up to
    the [support mailing
    list](http://lists.firehol.org/mailman/listinfo/firehol-support) and
    offer advice where you can. There's no formal role or sign-up process!

    Curating information at external sites is also helpful, for instance:

    -  At [Wikipedia](http://en.wikipedia.org/wiki/FireHOL)
    -  At the [Openhub Project](https://www.openhub.net/p/firehol)
