---
title: Documentation
submenu: documentation
---

Documentation
=============

We have a variety of documentation for different users:

-   [Reference documentation](#reference-documentation) for detailed information
-   [Guides and Tutorials](#guides-and-tutorials) on firewalling and QOS
*   [Frequently Asked Questions](/faq/) page
*   [FireHOL/FireQOS Wiki](https://github.com/ktsaou/firehol/wiki/) hosted at Github, for cutting edge features


Reference Documentation
-----------------------

Services list:

-   [FireHOL services list](/services/)

Manuals:

* [FireHOL Manual](/firehol-manual/)
* [FireQOS Manual](/fireqos-manual/)

Important Security Notes
------------------------

FireHOL can be no more secure than your use of it.

Please read [this FAQ](/faq/#trust). You should audit the results at
least once to ensure you are happy with the rules produced. The rules
that get output are extremely regular which should make the task fairly
straightforward.

You should also read [When FireHOL Runs](/guides/when-firehol-runs/) in
order to understand how FireHOL gets its results.

Please consider signing up to the [support mailing
list](http://lists.firehol.org/mailman/listinfo/firehol-support) to
ensure you are kept informed in the event that a security problem is
discovered.

Overall it is your responsibility to ensure the final firewall produced
behaves as you want it to. If in doubt we recommend that you seek help
from a firewall/networking professional.

Guides and Tutorials
--------------------

All of the tutorials assume you have [installed the
software](/installing/) and have the necessary rights to edit the
default FireHOL and FireQOS configuration files,
`/etc/firehol/firehol.conf`{.filename} and
`/etc/firehol/fireqos.conf`{.filename}.

The following tutorials are available:

<div class="list-with-header">

-   [FireHOL QuickStart](/tutorial/firehol-quickstart/) Suitable for the
    impatient. Ask FireHOL to guess a configuration which you can then
    customise.
-   [FireHOL New User](/tutorial/firehol-new-user/) Suitable for anyone
    who wants to use FireHOL for the first time.
-   [Upgrading FireHOL](/upgrade/) When you change major versions
    of FireHOL (e.g. 1.x to 2.x), read this guide.
-   [FireQOS New User](/tutorial/fireqos-new-user/) Suitable for anyone
    who wants to use FireQOS for the first time.
-   [FireHOL Configuration by Goal](/tutorial/firehol-by-goal/) Learn to
    translate your firewalling objectives into FireHOL rules.
-   [FireHOL Border Router Tutorial](/tutorial/firehol-border-router/)
    How to use FireHOL on a border router with multiple routes.
-   [FireHOL v1.x New User](/tutorial/firehol-v1/) Read this if you are
    just getting started and have a 1.x version of FireHOL.
-   [Adding Services to FireHOL](/guides/adding-services/)
-   [ICMPv6 recommendations](/guides/icmpv6-recommendations/)
-   [FireHOL Support for ipset](/guides/ipset/)
-   [Advanced Language Features](/guides/firehol-language/)
-   [When FireHOL Runs](/guides/when-firehol-runs/)
-   [Firewall Testing](/guides/firewall-testing/)
-   [Troubleshooting](/guides/firehol-troubleshooting/)
</div>

Got an idea for a guide or willing to write one? See
[here](/source-install/#get-involved).
