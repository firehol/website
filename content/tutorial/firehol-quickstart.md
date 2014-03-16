---
title: FireHOL QuickStart
submenu: documentation
---

# FireHOL QuickStart

First, [install the software](/installing/).

To gain a greater understanding and for step-by-step help building a
custom firewall, see the other [tutorials](/tutorial/). To have FireHOL
guess the configuration for your machine, simply run:

    firehol helpme > /tmp/firehol.conf

The purpose of the [helpme](/keyword/manref/firehol/helpme) feature
is to give you a configuration file that you can modify to get an operational
firewall quickly, especially if your firewalling and iptables knowledge
is limited. This feature does not stop or alter the running firewall of
your machine.

The output file *must* be edited before you use it, following the
embedded instructions.
