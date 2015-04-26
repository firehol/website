---
title: Firewall Testing
submenu: documentation
---

Firewall Testing
================

Normally you would need at least two computers to test a firewall.
That is still an option, however recent builds of FireHOL ship with a
tool, [vnetbuild](/vnetbuild-manual/), which helps you to build whole
virtual networks using only the standard network namespaces feature
present in recent Linux kernels.

You can run any commands you want in the namespaces and they will behave
with that view of the network. This is ideal if you want to control
everything without the expense of setting up lots of real or virtual hardware.

Otherwise, if you only have one machine or you want to test your live
firewall from outside, there are a number of [online services](#online-tools).

Testing Tools
-------------

To test your firewall there are a few software tools and a few online
services to help you. I suggest the following tools:

-   [Nessus](http://www.nessus.org) is probably the best open source
    security scanner available.
    [Nessus](http://www.nessus.org) not only checks the firewall of a
    host, but also scans for known application vulnerabilities.
    I highly recommend [Nessus](http://www.nessus.org) for periodic
    (weekly, monthly, etc) scans.
-   [Nmap](http://nmap.org/) ("Network Mapper") is an open source
    utility for network exploration or security auditing.

It is also possible to try out connections, see what effect your firewall
is having and monitor exactly what is happening on the network with tools
such as:

-   [netcat](http://netcat.sourceforge.net/) (`nc`) allows you to easily
    listen for connections and create connections and send data over
    both TCP and UDP.
-   [tcpdump](http://www.tcpdump.org/) allows you to see and capture
    the traffic seen by a network device.
-   [Wireshark](https://www.wireshark.org/) is a GUI equivalent which
    makes it very easy to decode and filter live traffic as well as
    being able to read data captured by `tcpdump`.

Other useful links:

-   [Top 125 Network Security Tools](http://sectool.org/)


Online Tools
------------

There are a number of sites that offer firewall testing services to
everyone:

-   [AuditMyPC](http://www.auditmypc.com/)
-   [Security Space](http://www.securityspace.com/sspace/index.html), a
    commercial service with a free scan. \
    These people are using something like
    [Nessus](http://www.nessus.org) if not
    [Nessus](http://www.nessus.org) itself).
-   [Shields UP!!](https://grc.com/x/ne.dll?bh0bkyd2) NanoProbe
    Technology Internet Security Testing for... Windows Users. (note:
    well, it says for Windows, but it is a port scanner with a limited
    range of ports to be scanned...)
-   [SubnetOnline.com](http://www.subnetonline.com/) provide tools
    which allow you to check if specific TCP ports are open for both
    [IPv4](http://www.subnetonline.com/pages/network-tools/online-port-scanner.php)
    and [IPv6](http://www.subnetonline.com/pages/ipv6-network-tools/online-ipv6-port-scanner.php) amongst other things.

Other testers on the net:

-   [Smurf Amplifier Registry (SAR)](http://www.powertech.no/smurf/) The
    SAR is a tool for Internet administrators being attacked by or
    implicated in smurf attacks, or those who wish to take precautions.
