---
title: FireHOL Source Code
submenu: source
---

FireHOL Source Code
===================

All of FireHOL is made available under the [GPLv2+
Licence](http://www.gnu.org/licenses/gpl-2.0.html).

Developers and non-developers alike are welcome
to [get involved](#get-involved) in the FireHOL project.

There is a [github firehol project](https://github.com/firehol) from
where you can get to each individual repository.

*   FireHOL, FireQOS, Link-Balancer, Update-Ipsets and VNetBuild are
    packaged as [firehol](https://github.com/firehol/firehol)

*   iprange is in repository [iprange](https://github.com/firehol/iprange)

*   netdata is in repository [netdata](https://github.com/firehol/netdata)

We also have GitHub repositories for:

*   [this website](https://github.com/firehol/website)

*   [build/release infrastructure](https://github.com/firehol/infrastructure)


Download
--------

Unless you want to help develop FireHOL you may want to [download and install a
packaged version](/installing/).

Otherwise, clone the source from a repository above. The basic
`git`{.command} commands to perform a clone are below.

Note: if you do not want to run `git`{.command} but are just looking for
the bleeding edge version, you can still use the [normal install
instructions](/installing/): the 'automatic builds' are updated
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

You need to set up autoconf, configure and make, then you can use the
commands in situ (or install with `make install`):

~~~~ {.programlisting}
./autogen.sh
./configure --enable-maintainer-mode
make
sudo ./sbin/firehol
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
    [repository](https://github.com/firehol/infrastructure).

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

    The [website source](https://github.com/firehol/website)
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
