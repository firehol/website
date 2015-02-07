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

The following guides and tutorials are available:

-------------------------------------------------------------------------------
Guide             Level         Description
----------------  ------------  -----------------------------------------------
[FireHOL New
User]             Beginner      Tutorial to set up your first FireHOL firewall.

[FireHOL Rules
by Goal]          Beginner      Learn to translate your firewalling objectives
                                into FireHOL rules.

[FireQOS New
User]             Beginner      Tutorial to set up your first FireQOS traffic
                                control configuration.

[Firewall
Testing]          Beginner      Links to tools which help you check your
                                firewall is doing what you want.

[Firewall
Troubleshooting]  Beginner      Firewall not behaving as you want? Learn
                                how read the logs to work out why.

[FireHOL
QuickStart]       Intermediate  For the impatient. Ask FireHOL to guess a
                                configuration which you then customise.

[Upgrading
FireHOL]          Intermediate  When you change major versions of FireHOL
                                (e.g. 1.x to 2.x), read this guide.

[Adding Services
to FireHOL]       Intermediate  How to extend FireHOL with your own service
                                definitions.

[FireHOL Support
for ipset]        Intermediate  FireHOL can make use of ipset to manage
                                lists of IP addresses and allow dynamic
                                changes without restarting the firewall.

[When FireHOL
Runs]             Intermediate  How FireHOL goes about its work. Important
                                to understanding the different phases and
                                what protection is offered at each.

[FireHOL Border
Router]           Advanced      How to use FireHOL on a border router with
                                multiple routes.

[ICMPv6
recommendations]  Advanced      Learn about the
                                [RFC 4890](http://tools.ietf.org/html/rfc4890)
                                recommendations and how FireHOL helps you
                                implement them.

[Language
Features]         Advanced      How you can use BASH in your configuration.

-----------------------------------------------------------

[FireHOL QuickStart]: /tutorial/firehol-quickstart/
[FireHOL New User]: /tutorial/firehol-new-user/
[FireHOL Border Router]: /tutorial/firehol-border-router/
[Upgrading FireHOL]: /upgrade/
[FireQOS New User]: /tutorial/fireqos-new-user/
[FireHOL Rules by Goal]: /tutorial/firehol-by-goal/
[Adding Services to FireHOL]: /guides/adding-services/
[ICMPv6 recommendations]: /guides/icmpv6-recommendations/
[FireHOL Support for ipset]: /guides/ipset/
[Language Features]: /guides/firehol-language/
[When FireHOL Runs]: /guides/when-firehol-runs/
[Firewall Testing]: /guides/firewall-testing/
[Firewall Troubleshooting]: /guides/firehol-troubleshooting/

The old (v1.x) new user guide is [here](/tutorial/firehol-v1/).

Got an idea for a guide or willing to write one? See
[here](/source-install/#get-involved).
